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

typedef NS_ENUM(NSUInteger, MMVideoPlayMode) {
    MMVideoPlayModeNormal,
    MMVideoPlayModePictureInPicture,
    MMVideoPlayModeFullScreen,
};

@class MMAssetPlayerControl;
@protocol MMAssetPlayerControlDelegate <NSObject>

@optional
-(void)shouldPlayMediaAtControl:(MMAssetPlayerControl*)control;
-(void)videoPlayerProgressUpdated:(NSTimeInterval)timeInterval;
-(void)control:(MMAssetPlayerControl*)control videoPlayModeChangedFrom:(MMVideoPlayMode)fromPlayMode to:(MMVideoPlayMode)toPlayMode;

@end

@class AVPlayer;
@interface MMAssetPlayerControl : UIView

@property(nonatomic, weak) AVPlayer* thePlayer;
@property(nonatomic, assign) id<MMAssetPlayerControlDelegate> delegate;
@property(nonatomic, readonly) BOOL isControllerShown;
@property(nonatomic, assign) BOOL isPlaying;

-(void)play;
-(void)pause;
-(void)stop;

-(void)showController;
-(void)hideController;

@end
