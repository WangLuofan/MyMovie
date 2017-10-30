//
//  MMMediaModifyCollectionViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPhotoManager.h"
#import "MMMediaItemModel.h"
#import "MMTransitionModifyView.h"
#import "MMAssetPlayerProgressView.h"
#import <AVFoundation/AVFoundation.h>
#import "MMMediaModifyItemCollectionViewCell.h"
#import "MMMediaAssetsCollectionViewFlowLayout.h"
#import "MMMediaModifyCollectionViewController.h"
#import "MMMediaPreviewViewController.h"
#import "MMMediaItemTransitionCollectionViewCell.h"
#import "MMMediaModifyCollectionViewController+MMMedia.h"

#define kMediaModifyItemCollectionViewCellIdentifier @"MediaModifyItemCollectionViewCellIdentifier"
#define kMediaItemTransitionCollectionViewCellIdentifier @"MediaItemTransitionCollectionViewCellIdentifier"

@interface MMMediaModifyCollectionViewController () <MMMediaAssetsCollectionViewFlowLayoutDelegate, MMTransitionModifyViewDelegate>

@property(nonatomic, strong) NSMutableArray* selectedItemIndexPath;

@end

@implementation MMMediaModifyCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _assetsDataSource = [NSMutableArray array];
    _audioDataSource = [NSMutableArray array];
    _selectedItemIndexPath = [NSMutableArray array];
    [self.collectionView registerNib:nibNamed(@"MMMediaModifyItemCollectionViewCell") forCellWithReuseIdentifier:kMediaModifyItemCollectionViewCellIdentifier];
    [self.collectionView registerNib:nibNamed(@"MMMediaItemTransitionCollectionViewCell") forCellWithReuseIdentifier:kMediaItemTransitionCollectionViewCellIdentifier];
    
    MMMediaAssetsCollectionViewFlowLayout* flowLayout = (MMMediaAssetsCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    flowLayout.minimumSpacing = 5.0f;
    
    return ;
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    if(_previewViewController == nil)
        _previewViewController = (MMMediaPreviewViewController*)[self.parentViewController.childViewControllers objectAtIndex:1];
    
    return ;
}

-(void)insertItemWithMediaItemModel:(MMMediaItemModel *)model {
    if(model.mediaType != MMAssetMediaTypeAudio) {
        
        if(model.mediaType == MMAssetMediaTypeVideo)
            model.duration = CMTimeGetSeconds(((MMMediaVideoModel*)model).mediaAsset.duration);
        else
            model.duration = 5.0f;
        
        if(_assetsDataSource.count == 0) {
            [_assetsDataSource addObject:model];
            
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:0]];
                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_assetsDataSource.count - 1 inSection:0]]];
            } completion:nil];
        }
        else {
            MMMediaTransitionModel* transitionModel = [[MMMediaTransitionModel alloc] init];
            transitionModel.mediaType = MMAssetMediaTypeTransition;
            transitionModel.duration = 0.0f;
            transitionModel.transitionType = TransitionTypeNone;
            [_assetsDataSource addObject:transitionModel];
            
            [_assetsDataSource addObject:model];
            
            [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_assetsDataSource.count - 2 inSection:0], [NSIndexPath indexPathForItem:_assetsDataSource.count - 1 inSection:0]]];
        }
        
    }else {
        if(_assetsDataSource.count == 0)
            return ;
        
        model.duration = CMTimeGetSeconds(((MMMediaAudioModel*)model).mediaAsset.duration);
        
        if(_audioDataSource.count == 0) {
            [_audioDataSource addObject:model];
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertSections:[NSIndexSet indexSetWithIndex:1]];
                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_audioDataSource.count - 1 inSection:1]]];
            } completion:nil];
        }else {
            [_audioDataSource addObject:model];
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:_audioDataSource.count - 1 inSection:1]]];
            } completion:nil];
        }
    }
    
    return ;
}

-(UIImage*)generateThumbnailWithArray:(NSArray*)imgsArray size:(CGSize) size {
    UIGraphicsBeginImageContext(size);
    
    for(int i = 0; i != imgsArray.count; ++i) {
        UIImage* img = [imgsArray objectAtIndex:i];
        [img drawInRect:CGRectMake(i * 50.0f, 0, 50.0f, 80.0f)];
    }
    
    UIImage* theImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImg;
}

-(UIImage*)generateThumbnailWithImage:(UIImage*)image size:(CGSize)size {
    UIGraphicsBeginImageContext(size);
    
    int idx = 0;
    CGFloat itemWidth = 0.0f;
    while(true) {
        if(itemWidth > size.width) break;
        
        [image drawInRect:CGRectMake(idx * 50.0f, 0, 50.0f, 80.0f)];
        itemWidth += 50.0f;
        ++idx;
    }
    
    UIImage* theImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return theImg;
}

-(void)prepareForPlay {
    NSInteger itemCount = 0;
    for (MMMediaItemModel* model in _assetsDataSource)
        if(model.mediaType == MMAssetMediaTypeImage)
            ++itemCount;
    
    if(itemCount == 0) {
        [self compositionWithVideoAssetsArray:_assetsDataSource audioAssets:_audioDataSource  complete:^(AVPlayerItem * playerItem) {
            
            _previewViewController.showProgress = NO;
            [_previewViewController playVideoWithPlayerItem:playerItem];
            
            return ;
        }];
        
        return ;
    }
    
    __block NSInteger convertedItems = 0;
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(3);
    
    for(MMMediaItemModel* model in _assetsDataSource) {
        if(model.mediaType == MMAssetMediaTypeImage) {
            dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
            
            dispatch_queue_t queue = dispatch_queue_create(model.identifer.UTF8String, NULL);
            
            dispatch_async(queue, ^{
                [self videoFromImageModel:(MMMediaImageModel*)model onQueue:queue complete:^(NSString * filePath) {
                    
                    ++convertedItems;
                    dispatch_semaphore_signal(semaphore);
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        _previewViewController.progressView.progress = convertedItems * 0.6 / itemCount;
                        
                        if(convertedItems == itemCount) {
                            [self compositionWithVideoAssetsArray:_assetsDataSource audioAssets:_audioDataSource complete:^(AVPlayerItem * playerItem) {
                                
                                _previewViewController.showProgress = NO;
                                [_previewViewController playVideoWithPlayerItem:playerItem];
                                
                                return ;
                            }];
                        }
                    });
                    return ;
                }];
            });
        }
    }
    
    return ;
}

-(CGFloat)widthForItemAtIndexPath:(NSIndexPath*)indexPath {
    MMMediaItemModel* model = nil;
    
    if(indexPath.section == 0)
        model = [_assetsDataSource objectAtIndex:(NSUInteger)indexPath.item];
    else
        model = [_audioDataSource objectAtIndex:(NSUInteger)indexPath.item];
    
    if(model.mediaType != MMAssetMediaTypeTransition) {
        NSTimeInterval seconds = (NSInteger)(model.duration + 1.0f);
        return seconds * 5.0f;
    }
    
    return 30.0f;
}

-(MMAssetMediaType)assetMediaTypeForItemAtIndexPath:(NSIndexPath*)indexPath {
    MMMediaItemModel* model = nil;
    if(indexPath.section == 0) {
        if(_assetsDataSource.count > indexPath.item)
            model = [_assetsDataSource objectAtIndex:(NSUInteger)indexPath.item];
    }
    else {
        if(_audioDataSource.count > indexPath.item)
            model = [_audioDataSource objectAtIndex:(NSUInteger)indexPath.item];
    }
    
    if(model != nil)
        return model.mediaType;
    return MMAssetMediaTypeUnknown;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    if(_assetsDataSource.count == 0)
        return 0;
    else if(_assetsDataSource.count != 0 && _audioDataSource.count == 0)
        return 1;
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    if(section == 0)
        return _assetsDataSource.count;
    return _audioDataSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell* cell = nil;
    
    MMMediaItemModel* model = nil;
    if(indexPath.section == 0)
        model = [_assetsDataSource objectAtIndex:(NSUInteger)indexPath.item];
    else
        model = [_audioDataSource objectAtIndex:(NSUInteger)indexPath.item];
    
    if(model.mediaType != MMAssetMediaTypeTransition) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMediaModifyItemCollectionViewCellIdentifier forIndexPath:indexPath];
        
        CGFloat itemWidth = [self widthForItemAtIndexPath:indexPath];
        
        if(model.mediaType == MMAssetMediaTypeVideo) {
            NSMutableArray* timeArr = [NSMutableArray array];
            CMTime cursorTime = kCMTimeZero;
            [timeArr addObject:[NSValue valueWithCMTime:cursorTime]];
            while(timeArr.count * 50.0f < itemWidth) {
                cursorTime = CMTimeAdd(cursorTime, CMTimeMake(1, 1));
                [timeArr addObject:[NSValue valueWithCMTime:cursorTime]];
            }
            
            ((MMMediaModifyItemCollectionViewCell*)cell).contentTitleLabel.hidden = YES;
            if(((MMMediaVideoModel*)model).thumbnail != nil)
                ((MMMediaModifyItemCollectionViewCell*)cell).contentImageView.image = ((MMMediaVideoModel*)model).thumbnail;
            else {
                NSMutableArray* imgsArray = [NSMutableArray array];
                [[AVAssetImageGenerator assetImageGeneratorWithAsset:((MMMediaVideoModel*)model).mediaAsset] generateCGImagesAsynchronouslyForTimes:timeArr completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
                    [imgsArray addObject:[UIImage imageWithCGImage:image]];
                    if(imgsArray.count == timeArr.count) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            ((MMMediaVideoModel*)model).thumbnail = [self generateThumbnailWithArray:imgsArray size:CGSizeMake(itemWidth, 80.0f)];
                            ((MMMediaModifyItemCollectionViewCell*)cell).contentImageView.image = ((MMMediaVideoModel*)model).thumbnail;
                        });
                    }
                }];
            }
        } else if(model.mediaType == MMAssetMediaTypeImage) {
            ((MMMediaModifyItemCollectionViewCell*)cell).contentTitleLabel.hidden = YES;
            if(((MMMediaImageModel*)model).thumbnail != nil)
                ((MMMediaModifyItemCollectionViewCell*)cell).contentImageView.image = ((MMMediaImageModel*)model).thumbnail;
            else {
                ((MMMediaImageModel*)model).thumbnail = [self generateThumbnailWithImage:[UIImage imageWithData:((MMMediaImageModel*)model).srcImage] size:CGSizeMake(itemWidth, 80.0f)];
                ((MMMediaModifyItemCollectionViewCell*)cell).contentImageView.image = ((MMMediaImageModel*)model).thumbnail;
            }
        }else if(model.mediaType == MMAssetMediaTypeAudio) {
            ((MMMediaModifyItemCollectionViewCell*)cell).contentTitleLabel.hidden = NO;
            ((MMMediaModifyItemCollectionViewCell*)cell).contentTitleLabel.text = [NSString stringWithFormat:@"%@-%@", ((MMMediaAudioModel*)model).title, ((MMMediaAudioModel*)model).artist];
        }
    }else if(model.mediaType == MMAssetMediaTypeTransition) {
        cell = [collectionView dequeueReusableCellWithReuseIdentifier:kMediaItemTransitionCollectionViewCellIdentifier forIndexPath:indexPath];
        ((MMMediaItemTransitionCollectionViewCell*)cell).transtionType = ((MMMediaTransitionModel*)model).transitionType;
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MMMediaVideoModel* model = nil;
    if(indexPath.section == 0)
        model = [_assetsDataSource objectAtIndex:(NSUInteger)indexPath.item];
    else
        model = [_audioDataSource objectAtIndex:(NSUInteger)indexPath.item];
    
    if(model.mediaType != MMAssetMediaTypeTransition) {
        BOOL bDeselect = NO;
        for (NSIndexPath* selectedIndexPath in _selectedItemIndexPath) {
            if(selectedIndexPath.item == indexPath.item) {
                [collectionView deselectItemAtIndexPath:selectedIndexPath animated:YES];
                [_selectedItemIndexPath removeObject:selectedIndexPath];
                bDeselect = YES;
                break;
            }
        }
        
        if(bDeselect == NO)
            [_selectedItemIndexPath addObject:indexPath];
    } else {
        if(_transitionModifyView == nil) {
            _transitionModifyView = (MMTransitionModifyView*)[[[NSBundle mainBundle] loadNibNamed:@"MMTransitionModifyView" owner:nil options:nil] objectAtIndex:0];
            _transitionModifyView.delegate = self;
        }
        [_transitionModifyView showInView:self.parentViewController.navigationController.view withModel:model];
    }
    
    return ;
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath {
    for(NSIndexPath* selectedIndexpath in _selectedItemIndexPath) {
        if(selectedIndexpath.item == indexPath.item) {
            [_selectedItemIndexPath removeObject:selectedIndexpath];
            break;
        }
    }
    return ;
}

#pragma mark - MMMediaAssetsCollectionViewFlowLayoutDelegate
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout *)layou sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    MMMediaItemModel* model = nil;
    if(indexPath.section == 0)
        model = [_assetsDataSource objectAtIndex:(NSUInteger)indexPath.item];
    else
        model = [_audioDataSource objectAtIndex:(NSUInteger)indexPath.item];
    
    if(model.mediaType != MMAssetMediaTypeTransition)
        return CGSizeMake([self widthForItemAtIndexPath:indexPath], 80.0f);
    return CGSizeMake(30.0f, 30.0f);
}

-(NSUInteger)collectionView:(UICollectionView *)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout *)layout assetsTypeForItemAtIndexPath:(NSIndexPath *)indexPath {
    return [self assetMediaTypeForItemAtIndexPath:indexPath];
}

-(void)collectionView:(UICollectionView *)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout *)layout didDeleteItemAtIndexPath:(NSIndexPath *)indexPath {
    MMMediaItemModel* model = nil;
    if(indexPath.section == 0)
        model = [_assetsDataSource objectAtIndex:(NSUInteger)indexPath.item];
    else
        model = [_audioDataSource objectAtIndex:(NSUInteger)indexPath.item];
    
    if(model.mediaType == MMAssetMediaTypeAudio) {
        [_audioDataSource removeObjectAtIndex:(NSUInteger)indexPath.item];
        if(_audioDataSource.count == 0) {
            [collectionView performBatchUpdates:^{
                [collectionView deleteSections:[NSIndexSet indexSetWithIndex:1]];
            } completion:nil];
        }else {
            [collectionView performBatchUpdates:^{
                [collectionView deleteItemsAtIndexPaths:@[indexPath]];
            } completion:nil];
        }
    }else if(model.mediaType == MMAssetMediaTypeVideo || model.mediaType == MMAssetMediaTypeImage) {
        NSArray* indexPaths = nil;
        if(indexPath.item == 0) {
            if(_assetsDataSource.count > (indexPath.item + 1)) {
                [_assetsDataSource removeObjectAtIndex:(NSUInteger)indexPath.item];
                [_assetsDataSource removeObjectAtIndex:(NSUInteger)(indexPath.item + 1)];
                indexPaths = @[indexPath, [NSIndexPath indexPathForItem:indexPath.item + 1 inSection:indexPath.section]];
            }else {
                [_assetsDataSource removeObjectAtIndex:(NSUInteger)indexPath.item];
                
                NSMutableIndexSet* indexSet = [NSMutableIndexSet indexSet];
                [indexSet addIndex:0];
                
                if(_audioDataSource.count != 0) {
                    [_audioDataSource removeAllObjects];
                    [indexSet addIndex:1];
                }
                
                [collectionView performBatchUpdates:^{
                    [collectionView deleteSections:indexSet];
                } completion:nil];
            }
        }else {
            [_assetsDataSource removeObjectAtIndex:(NSUInteger)(indexPath.item)];
            [_assetsDataSource removeObjectAtIndex:(NSUInteger)indexPath.item - 1];
            indexPaths = @[indexPath, [NSIndexPath indexPathForItem:indexPath.item - 1 inSection:indexPath.section]];
        }
        
        if(indexPaths != nil) {
            [collectionView performBatchUpdates:^{
                [collectionView deleteItemsAtIndexPaths:indexPaths];
            } completion:nil];
        }
        
    }
    return ;
}

-(void)collectionView:(UICollectionView *)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout *)layout didAdjustItemAtIndexPath:(NSIndexPath *)indexPath toWidth:(CGFloat)width {
    MMMediaItemModel* curModel = nil;
    if(indexPath.section == 0)
        curModel = [_assetsDataSource objectAtIndex:(NSUInteger)indexPath.item];
    else
        curModel = [_audioDataSource objectAtIndex:(NSUInteger)indexPath.item];
    
    curModel.duration = width / 5.0f;
    
    return ;
}

-(BOOL)collectionView:(UICollectionView *)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout *)layout canAdjustItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_selectedItemIndexPath containsObject:indexPath];
}

-(BOOL)collectionView:(UICollectionView *)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout *)layout canMoveItemAtIndexPath:(NSIndexPath *)indexPath {
    return [_selectedItemIndexPath containsObject:indexPath] == NO;
}

-(void)collectionView:(UICollectionView *)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout *)layout didMoveItemAtIndexPath:(NSIndexPath *)srcIndexPath toIndexPath:(NSIndexPath *)dstIndexPath {
    if(srcIndexPath.section == dstIndexPath.section) {
        if(srcIndexPath.section == 0)
            [_assetsDataSource exchangeObjectAtIndex:(NSUInteger)srcIndexPath.item withObjectAtIndex:(NSUInteger)dstIndexPath.item];
        else
            [_audioDataSource exchangeObjectAtIndex:(NSUInteger)srcIndexPath.item withObjectAtIndex:(NSUInteger)dstIndexPath.item];
    }
    
    [collectionView reloadSections:[NSIndexSet indexSetWithIndex:(NSUInteger)srcIndexPath.section]];
    return ;
}

#pragma mark - MMTransitionModifyViewDelegate
-(void)transitionViewDidHide:(MMTransitionModifyView *)transitionView {
    if(self.collectionView.indexPathsForSelectedItems.count != 0)
        [self.collectionView deselectItemAtIndexPath:[[self.collectionView indexPathsForSelectedItems] objectAtIndex:0] animated:YES];
    return ;
}

-(void)transitionView:(MMTransitionModifyView *)transtionView willSaveDataWithModel:(MMMediaItemModel *)model {
    NSIndexPath* indexPath = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0];
    
    MMMediaItemModel* curModel = nil;
    if(indexPath.section == 0)
        curModel = [_assetsDataSource objectAtIndex:(NSUInteger)indexPath.item];
    else
        curModel = [_audioDataSource objectAtIndex:(NSUInteger)indexPath.item];
    
    curModel.duration = model.duration;
    ((MMMediaTransitionModel*)curModel).transitionType = ((MMMediaTransitionModel*)model).transitionType;
    [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
    return ;
}

@end
