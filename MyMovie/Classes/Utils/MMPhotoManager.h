//
//  MMPhotoManager.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/11.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <Photos/Photos.h>
#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, MMAuthorizationStatus) {
    MMAuthorizationStatusNotDetermined = 0,
    MMAuthorizationStatusRestricted,
    MMAuthorizationStatusDenied,
    MMAuthorizationStatusAuthorized
};

typedef NS_ENUM(NSUInteger, MMAssetMediaType) {
    MMAssetMediaTypeUnknown = 0,
    MMAssetMediaTypeImage = 1,
    MMAssetMediaTypeVideo = 2,
    MMAssetMediaTypeAudio = 3,
    MMAssetMediaTypeTransition = 4,
    MMAssetMediaTypeAll = 5,
};

@interface MMPhotoManager : NSObject

+(instancetype)sharedManager;
-(MMAuthorizationStatus)authorizationStatus;
-(void)requestImageForAsset:(PHAsset*)asset TargetSize:(CGSize)size WhenComplelte:(void(^)(UIImage*, NSDictionary*))complete;
-(void)requestOriginImageForAsset:(PHAsset*)asset WhenComplete:(void(^)(NSData*))complete;
-(void)requestVideoForAsset:(PHAsset*)asset WhenComplete:(void(^)(AVAsset*))complete;
-(NSArray*)postImageForAlbum:(PHAssetCollection*)album targetSize:(CGSize)size;
-(NSArray*)fetchAllPhotosForAlbum:(PHAssetCollection*)album mediaType:(MMAssetMediaType)mediaType;
-(NSArray*)fetchAllAssetsForAlbum:(PHAssetCollection*)album;
-(NSArray*)fetchAllPhotoAlbums;
-(void)requestAuthorization:(void(^)(MMAuthorizationStatus))handler;

@end
