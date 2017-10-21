//
//  MMPhotosCollectionViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/12.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPhotoManager.h"
#import "MMMediaItemModel.h"
#import "MMPhotosItemCollectionViewCell.h"
#import "MMPhotosCollectionViewController.h"
#import "MMMediaPreviewViewController.h"
#import "MMMediaModifyCollectionViewController.h"

#define kDefaultItemsPerRow 4
#define kItemInternalSpacing 5
#define kPhotosCollectionViewCellIdentifier @"PhotosCollectionViewCellIdentifier"

@interface MMPhotosCollectionViewController () <MMPhotosItemCollectionViewCellDelegate>

@property(nonatomic, copy) NSArray* assets;
@property(nonatomic, weak) MMMediaModifyCollectionViewController* modifyViewController;

@end

@implementation MMPhotosCollectionViewController

- (instancetype)initWithAssets:(NSArray *)assets
{
    self = [super init];
    if (self) {
        _assets = assets;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    [self.collectionView registerNib:nibNamed(@"MMPhotosItemCollectionViewCell") forCellWithReuseIdentifier:kPhotosCollectionViewCellIdentifier];
    
    UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    flowLayout.minimumLineSpacing = kItemInternalSpacing;
    flowLayout.minimumInteritemSpacing = kItemInternalSpacing;
    
    CGFloat itemSize = ((SCREEN_HEIGHT / 2) - (kDefaultItemsPerRow + 1) * kItemInternalSpacing) / kDefaultItemsPerRow;
    flowLayout.itemSize = CGSizeMake(itemSize, itemSize);
    
    return ;
}

-(NSString*)convertTimeIntervalToTime:(NSTimeInterval)timeInterval {
    NSInteger hour = (NSInteger)(timeInterval / 3600);
    NSInteger minute = (NSInteger)(timeInterval / 60);
    NSInteger second = (NSInteger)(timeInterval - hour * 3600 - minute * 60);
    
    NSString* timeStr = @"";
    
    if(hour != 0)
        timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@"%02ld", (long)hour]];
    
    if(hour != 0)
        timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@":%02ld", minute]];
    else
        timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@"%02ld", minute]];
    
    if(second == 0) second += 1;
    timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@":%02ld", second]];
    
    return timeStr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return _assets.count;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMPhotosItemCollectionViewCell* cell = (MMPhotosItemCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kPhotosCollectionViewCellIdentifier forIndexPath:indexPath];
    
    PHAsset* asset = (PHAsset*)[_assets objectAtIndex:indexPath.item];
    
    if(asset.mediaType != PHAssetMediaTypeVideo)
        cell.durLabel.hidden = YES;
    else {
        cell.durLabel.hidden = NO;
        cell.durLabel.text = [self convertTimeIntervalToTime:asset.duration];
    }
    
    CGFloat itemSize = (SCREEN_WIDTH - (kDefaultItemsPerRow + 1) * kItemInternalSpacing) / kDefaultItemsPerRow;
    [[MMPhotoManager sharedManager] requestImageForAsset:asset TargetSize:CGSizeMake(itemSize, itemSize) WhenComplelte:^(UIImage * image, NSDictionary * info) {
        dispatch_async(dispatch_get_main_queue(), ^{
            cell.imageView.image = image;
        });
    }];
    
    cell.delegate = self;
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    PHAsset* asset = (PHAsset*)[_assets objectAtIndex:indexPath.item];
    
    MMMediaPreviewViewController* previewController = (MMMediaPreviewViewController*)[self.navigationController.parentViewController.parentViewController.childViewControllers objectAtIndex:1];
    previewController.mediaAsset = asset;
    
    return ;
}

#pragma mark - MMPhotosItemCollectionViewCellDelegate
-(void)mediaAssetsSelectedInItemCell:(MMPhotosItemCollectionViewCell *)ItemCell {
    if(_modifyViewController == nil)
        _modifyViewController = [self.navigationController.parentViewController.parentViewController.childViewControllers objectAtIndex:2];
    
    NSIndexPath* indexPath = [self.collectionView indexPathForCell:ItemCell];
    if(indexPath != nil) {
        PHAsset* mediaAsset = (PHAsset*)[_assets objectAtIndex:indexPath.item];
        
        if(mediaAsset != nil) {
            if(mediaAsset.mediaType == PHAssetMediaTypeVideo) {
                [[PHImageManager defaultManager] requestAVAssetForVideo:mediaAsset options:nil resultHandler:^(AVAsset * _Nullable asset, AVAudioMix * _Nullable audioMix, NSDictionary * _Nullable info) {
                    if(asset != nil) {
                        NSArray* keys = @[@"commonMetadata", @"duration", @"tracks"];
                        [asset loadValuesAsynchronouslyForKeys:keys completionHandler:^{
                            AVKeyValueStatus comStatus = [asset statusOfValueForKey:@"commonMetadata" error:nil];
                            AVKeyValueStatus durStatus = [asset statusOfValueForKey:@"duration" error:nil];
                            AVKeyValueStatus traStatus = [asset statusOfValueForKey:@"tracks" error:nil];
                            
                            if(comStatus == AVKeyValueStatusLoaded && durStatus == AVKeyValueStatusLoaded && traStatus == AVKeyValueStatusLoaded) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    MMMediaVideoModel* itemModel = [[MMMediaVideoModel alloc] init];
                                    itemModel.mediaType = mediaAsset.mediaType;
                                    itemModel.mediaAsset = asset;
                                    
                                    [_modifyViewController insertItemWithMediaItemModel:itemModel];
                                });
                            }
                        }];
                    }
                }];
            }else if(mediaAsset.mediaType == PHAssetMediaTypeImage) {
                [[PHImageManager defaultManager] requestImageDataForAsset:mediaAsset options:nil resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        MMMediaImageModel* itemModel = [[MMMediaImageModel alloc] init];
                        itemModel.mediaType = mediaAsset.mediaType;
                        itemModel.srcImage = [imageData copy];
                        
                        [_modifyViewController insertItemWithMediaItemModel:itemModel];
                    });
                }];
            }
        }
    }
    return ;
}

@end
