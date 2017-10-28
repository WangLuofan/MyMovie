//
//  MMImageToVideoUtils.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/27.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@class MMMediaImageModel;
@class AVPlayerItem;
@class MMAssetPlayerProgressView;

@interface MMImageToVideoUtils : NSObject

+(void)videoFromImageModel:(MMMediaImageModel*)model onQueue:(dispatch_queue_t)queue docPath:(NSString*)docPath complete:(void(^)(NSString*))complete;
+(void)compositionWithVideoAssetsArray:(NSArray*)videoAssetsArray audioAssets:(NSArray*)audioAssetsArray progress:(MMAssetPlayerProgressView*)progress docPath:(NSString*)docPath complete:(void(^)(AVPlayerItem*))complete;

@end
