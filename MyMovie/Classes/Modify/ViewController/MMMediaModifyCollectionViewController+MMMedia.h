//
//  MMMediaModifyCollectionViewController+MMMedia.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/29.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMMediaModifyCollectionViewController.h"

@class MMMediaImageModel;
@class AVPlayerItem;
@class MMAssetPlayerProgressView;

@interface MMMediaModifyCollectionViewController (MMMedia)

-(void)videoFromImageModel:(MMMediaImageModel*)model onQueue:(dispatch_queue_t)queue complete:(void(^)(NSString*))complete;
-(void)compositionWithVideoAssetsArray:(NSArray*)videoAssetsArray audioAssets:(NSArray*)audioAssetsArray complete:(void(^)(AVPlayerItem*))complete;

@end
