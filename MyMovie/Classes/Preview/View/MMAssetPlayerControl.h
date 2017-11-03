//
//  MMAssetPlayerControl.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/26.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MMVideoPlayStatus) {
    MMVideoPlayStatusPlaying,
    MMVideoPlayStatusPaused,
    MMVideoPlayStatusStoped,
    MMVideoPlayStatusSeeking,
    MMVideoPlayStatusFailed,
};

@class MMAssetPlayerControl;
@protocol MMAssetPlayerControlDelegate <NSObject>

@optional
-(void)shouldPlayMediaAtControl:(MMAssetPlayerControl*)control;
-(void)videoPlayerProgressUpdated:(NSTimeInterval)timeInterval;

@end

@class AVPlayer;
@interface MMAssetPlayerControl : UIView

@property(nonatomic, weak) AVPlayer* thePlayer;
@property(nonatomic, assign) id<MMAssetPlayerControlDelegate> delegate;
@property(nonatomic, readonly) BOOL isControllerShown;

-(void)showController;
-(void)hideController;

@end
