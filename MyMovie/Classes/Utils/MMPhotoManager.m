//
//  MMPhotoManager.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/11.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPhotoManager.h"

#define kDefaultPostImageItemCount 3
static MMPhotoManager* _instance;
@implementation MMPhotoManager

- (instancetype)init
{
    if(_instance == nil) {
        self = [super init];
        
        return self;
    }else {
        @throw [NSException exceptionWithName:@"初始化失败" reason:@"请使用+sharedManager方法" userInfo:nil];
    }
    
    return nil;
}

+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _instance = [[MMPhotoManager alloc] init];
    });
    
    return _instance;
}

-(void)requestAuthorization:(void (^)(MMAuthorizationStatus))handler {
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        if(handler)
            dispatch_async(dispatch_get_main_queue(), ^{
                handler((MMAuthorizationStatus)status);
            });
    }];
    return ;
}

-(MMAuthorizationStatus)authorizationStatus {
    return (MMAuthorizationStatus)[PHPhotoLibrary authorizationStatus];
}

-(NSArray*)fetchAllPhotoAlbums {
    PHFetchResult<PHAssetCollection*>* customAlbum = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAny options:nil];
    PHFetchResult<PHAssetCollection*>* allPhoto = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    PHFetchResult<PHAssetCollection*>* panoramas = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumPanoramas options:nil];
    PHFetchResult<PHAssetCollection*>* selfPortraits = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits options:nil];
    NSArray* allAlubms = @[allPhoto, panoramas, selfPortraits, customAlbum];
    
    NSMutableArray* albums = [NSMutableArray array];
    for (PHFetchResult* result in allAlubms) {
        [result enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            [albums addObject:obj];
        }];
    }
    return albums;
}

-(NSArray *)fetchAllPhotosForAlbum:(PHAssetCollection *)album mediaType:(MMAssetMediaType)mediaType {
    if(mediaType == MMAssetMediaTypeUnknown)
        return nil;
    
    NSMutableArray* photos = [NSMutableArray array];
    
    PHFetchOptions* options = [[PHFetchOptions alloc] init];
    
    if(mediaType != MMAssetMediaTypeAll)
        options.predicate = [NSPredicate predicateWithFormat:@"mediaType == %ld", mediaType];
    options.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:YES]];
    
    PHFetchResult* result = [PHAsset fetchAssetsInAssetCollection:album options:options];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [photos addObject:obj];
    }];
    
    return photos;
}

-(NSArray*)fetchAllAssetsForAlbum:(PHAssetCollection*)album {
    return [self fetchAllPhotosForAlbum:album mediaType:MMAssetMediaTypeAll];
}

-(NSArray*)postImageForAlbum:(PHAssetCollection *)album targetSize:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    
    NSArray* photos = [self fetchAllAssetsForAlbum:album];
    
    UIImage* post = nil;
    if(photos.count > 0) {
        PHAsset* asset = (PHAsset*)[photos objectAtIndex:0];
        PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
        options.synchronous = YES;
        
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [result drawInRect:CGRectMake(0, 0, size.width, size.height)];
        }];
    }
    
    post = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(post == nil)
        return @[[NSNull null], photos];
    return @[post, photos];
}

-(void)requestImageForAsset:(PHAsset *)asset TargetSize:(CGSize)size WhenComplelte:(void (^)(UIImage *, NSDictionary*))complete {
    PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = NO;
    options.synchronous = NO;
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        if(complete)
            complete(result, info);
    }];
    return ;
}

-(void)requestOriginImageForAsset:(PHAsset *)asset WhenComplete:(void (^)(NSData *))complete {
    PHImageRequestOptions* options = [[PHImageRequestOptions alloc] init];
    options.networkAccessAllowed = NO;
    options.synchronous = NO;
    
    [[PHImageManager defaultManager] requestImageDataForAsset:asset options:options resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
        if(complete)
            complete(imageData);
    }];
    return ;
}

-(void)requestVideoForAsset:(PHAsset *)asset WhenComplete:(void (^)(AVAsset *))complete {
    PHVideoRequestOptions* options = [[PHVideoRequestOptions alloc] init];
    options.networkAccessAllowed = NO;
    
    [[PHImageManager defaultManager] requestAVAssetForVideo:asset options:options resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
        if(complete)
            complete(asset);
    }];
    
    return ;
}

@end
