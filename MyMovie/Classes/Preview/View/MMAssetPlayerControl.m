//
//  MMAssetPlayerControl.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/26.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "UIImage+MMImage.h"
#import "MMMediaTimeUtils.h"
#import "MMAssetPlayerControl.h"
#import "MMTimerManager.h"
#import <AVFoundation/AVFoundation.h>

@interface MMAssetPlayerControl()

@property (weak, nonatomic) IBOutlet UIButton *playBtn;
@property(nonatomic, weak) IBOutlet UISlider* progressSlider;
@property (weak, nonatomic) IBOutlet UILabel *curTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *totTimeLabel;
@property(nonatomic, assign) BOOL isAnimationInProgress;

@property(nonatomic, weak) NSTimer* progressTimer;
@property(nonatomic, assign) MMVideoPlayMode videoPlayMode;

@end

@implementation MMAssetPlayerControl

-(void)awakeFromNib {
    [super awakeFromNib];
    _isControllerShown = YES;
    _videoPlayMode = MMVideoPlayModeNormal;
    
    [_progressSlider setThumbImage:[UIImage imageNamed:@"knob" scale:0.5f] forState:UIControlStateNormal];
    [_progressSlider setThumbImage:[UIImage imageNamed:@"knob_highlighted" scale:0.5f] forState:UIControlStateHighlighted];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playToEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    return ;
}

-(void)playToEnd:(NSNotification*)notification {
    if(_progressTimer != nil)
        [[MMTimerManager sharedManager] removeTimer:_progressTimer];
    
    _isPlaying = NO;
    _curTimeLabel.text = @"00:00";
    [_playBtn setImage:imageNamed(@"tp_play_icon") forState:UIControlStateNormal];
    _progressSlider.value = 0.0f;
    
    [self.thePlayer replaceCurrentItemWithPlayerItem:nil];
    return ;
}

-(void)setThePlayer:(AVPlayer *)thePlayer {
    _thePlayer = thePlayer;
    
    _progressSlider.maximumValue = CMTimeGetSeconds(_thePlayer.currentItem.duration);
    _curTimeLabel.text = @"00:00";
    _totTimeLabel.text = [MMMediaTimeUtils convertTimeIntervalToTime:_progressSlider.maximumValue];
    [_playBtn setImage:imageNamed(@"tp_play_icon") forState:UIControlStateNormal];
    
    return;
}

- (IBAction)zoom:(UIButton *)sender {
    
    MMVideoPlayMode currentMode = MMVideoPlayModeNormal;
    if(_videoPlayMode == MMVideoPlayModeNormal) {
        [sender setImage:[UIImage imageNamed:@"Zoom_In"] forState:UIControlStateNormal];
        currentMode = MMVideoPlayModePictureInPicture;
    }else if(_videoPlayMode == MMVideoPlayModePictureInPicture) {
        [sender setImage:[UIImage imageNamed:@"Zoom_Out"] forState:UIControlStateNormal];
        currentMode = MMVideoPlayModeFullScreen;
    }else {
        [sender setImage:[UIImage imageNamed:@"Zoom_Out"] forState:UIControlStateNormal];
        currentMode = MMVideoPlayModeNormal;
    }
    
    if([self.delegate respondsToSelector:@selector(control:videoPlayModeChangedFrom:to:)])
        [self.delegate control:self videoPlayModeChangedFrom:_videoPlayMode to:currentMode];
    _videoPlayMode = currentMode;
    
    return ;
}

-(NSTimer *)progressTimer {
    if(_progressTimer == nil) {
        _progressTimer = [[MMTimerManager sharedManager] addTimerWithTimeInterval:0.5f repeats:YES target:self selector:@selector(progressTimerEventHandler:)];
    }
    return _progressTimer;
}

-(void)progressTimerEventHandler:(NSTimer*)timer {
    _progressSlider.value = CMTimeGetSeconds(_thePlayer.currentTime);
    _curTimeLabel.text = [MMMediaTimeUtils convertTimeIntervalToTime:_progressSlider.value];
    
    if([self.delegate respondsToSelector:@selector(videoPlayerProgressUpdated:)])
        [self.delegate videoPlayerProgressUpdated:_progressSlider.value];
    return ;
}

-(void)play {
    [_thePlayer play];
    _isPlaying = YES;
    
    if(_progressTimer == nil)
        [[NSRunLoop currentRunLoop] addTimer:self.progressTimer forMode:NSDefaultRunLoopMode];
    else
        [self.progressTimer setFireDate:[[NSDate date] dateByAddingTimeInterval:1.0f]];
    
    return ;
}

-(void)pause {
    [_thePlayer pause];
    
    _isPlaying = NO;
    if(_progressTimer != nil)
        [self.progressTimer setFireDate:[NSDate distantFuture]];
    
    return ;
}

- (IBAction)playAction:(UIButton *)sender {
    if(self.thePlayer.currentItem == nil) {
        if([self.delegate respondsToSelector:@selector(shouldPlayMediaAtControl:)])
            [self.delegate shouldPlayMediaAtControl:self];
        return ;
    }
    
    if(_isPlaying == NO) {
        [self play];
        
        [sender setImage:imageNamed(@"tp_pause_icon") forState:UIControlStateNormal];
        [MMNotificationCenter postNotificationName:kMovieVideoPlayStateChangedNotification object:nil userInfo:@{@"status" : @(MMVideoPlayStatusPlaying), @"duration" : [NSValue valueWithCMTime:_thePlayer.currentItem.duration]}];
    }else {
        [self pause];
        
        [sender setImage:imageNamed(@"tp_play_icon") forState:UIControlStateNormal];
        [MMNotificationCenter postNotificationName:kMovieVideoPlayStateChangedNotification object:nil userInfo:@{@"status" : @(MMVideoPlayStatusPaused)}];
    }
    return ;
}

-(void)stop {
    [_thePlayer pause];
    [_thePlayer seekToTime:kCMTimeZero];
    
    [self playToEnd:nil];
    
    [MMNotificationCenter postNotificationName:kMovieVideoPlayStateChangedNotification object:nil userInfo:@{@"status" : @(MMVideoPlayStatusStoped)}];
    return ;
}

- (IBAction)stopAction:(UIButton *)sender {
    [self stop];
    return ;
}

-(void)seekToTime:(CMTime)time {
    if(CMTIME_IS_INVALID(time) == true)
        return ;
    
    [self pause];
    [_thePlayer seekToTime:time toleranceBefore:kCMTimeZero toleranceAfter:kCMTimeZero completionHandler:^(BOOL finished) {
        if(finished) {
            if([self.delegate respondsToSelector:@selector(videoPlayerProgressUpdated:)])
                [self.delegate videoPlayerProgressUpdated:_progressSlider.value];
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self play];
            });
            
            [MMNotificationCenter postNotificationName:kMovieVideoPlayStateChangedNotification object:nil userInfo:@{@"status" : @(MMVideoPlayStatusSeeking), @"currentTime" : [NSValue valueWithCMTime:_thePlayer.currentTime]}];
        }
    }];
    
    return ;
}

- (IBAction)backwardAction:(UIButton *)sender {
    return [self seekToTime:CMTimeSubtract(_thePlayer.currentTime, CMTimeMake(5, 1))];
}

- (IBAction)forwardAction:(UIButton *)sender {
    return [self seekToTime:CMTimeAdd(_thePlayer.currentTime, CMTimeMake(5, 1))];
}

- (IBAction)beforeProgressChanged:(UISlider *)sender {
    if(_progressTimer != nil) {
        [_progressTimer setFireDate:[NSDate distantFuture]];
    }
    return ;
}

- (IBAction)progressValueChanged:(UISlider *)sender {
    _curTimeLabel.text = [MMMediaTimeUtils convertTimeIntervalToTime:sender.value];
    if([self.delegate respondsToSelector:@selector(videoPlayerProgressUpdated:)])
        [self.delegate videoPlayerProgressUpdated:sender.value];
    return ;
}

- (IBAction)progressChanged:(UISlider *)sender {
    return [self seekToTime:CMTimeMakeWithSeconds(sender.value, _thePlayer.currentTime.timescale)];
}

-(void)showController {
    if(_isAnimationInProgress == YES)
        return ;
    
    _isAnimationInProgress = YES;
    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
        self.alpha = 1.0f;
    } completion:^(BOOL finished) {
        if(finished) {
            _isControllerShown = YES;
            _isAnimationInProgress = NO;
        }
    }];
    return ;
}

-(void)hideController {
    if(_isAnimationInProgress == YES)
        return ;
    
    _isAnimationInProgress = YES;
    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
        self.alpha = 0.0f;
    } completion:^(BOOL finished) {
        if(finished) {
            _isControllerShown = NO;
            _isAnimationInProgress = NO;
        }
    }];
    return ;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
