//
//  MMMediaPreviewViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPhotoManager.h"
#import "MMAssetPlayerProgressView.h"
#import "MMAssetPlayerControl.h"
#import <AVFoundation/AVFoundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "MMMediaPreviewViewController.h"
#import "MMMediaModifyCollectionViewController.h"

@interface MMMediaPreviewViewController () <UIGestureRecognizerDelegate, MMAssetPlayerControlDelegate>

//Image
@property(nonatomic, weak) IBOutlet UIImageView* previewImageView;
@property (weak, nonatomic) IBOutlet UIView *assetsPlayerView;

//Video
@property(nonatomic, strong) AVPlayer* thePlayer;
@property(nonatomic, strong) AVPlayerLayer* thePlayerLayer;
@property(nonatomic, strong) MMAssetPlayerControl* playerControl;

//dim
@property(nonatomic, strong) UIView* dimBgView;

@property(nonatomic, assign) BOOL isVideoPlaying;

//progress
@property(nonatomic, strong) MMAssetPlayerProgressHostView* progressHostView;
@property(nonatomic, weak) MMMediaModifyCollectionViewController* mediaModifyViewController;

@end

@implementation MMMediaPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _playerControl = (MMAssetPlayerControl*)[[[NSBundle mainBundle] loadNibNamed:@"MMAssetPlayerControl" owner:nil options:nil] objectAtIndex:0];
    _playerControl.delegate = self;
    [_assetsPlayerView addSubview:_playerControl];
    [_playerControl mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.bottom.and.trailing.mas_equalTo(_assetsPlayerView);
        make.height.mas_equalTo(50.0f);
    }];
    
    [_assetsPlayerView.layer insertSublayer:self.thePlayerLayer atIndex:0];
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showPlayerControl:)];
    tapGesture.delegate = self;
    [_assetsPlayerView addGestureRecognizer:tapGesture];
    
    _progressHostView = [[MMAssetPlayerProgressHostView alloc] init];
    _progressHostView.hidden = YES;
    [self.view addSubview:_progressHostView];
    [_progressHostView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.bottom.and.trailing.and.top.mas_equalTo(self.view);
    }];
    
    return ;
}

-(void)setShowProgress:(BOOL)showProgress {
    _showProgress = showProgress;
    _progressHostView.hidden = !showProgress;
    _progressView.progress = 0.0f;
    return ;
}

-(MMAssetPlayerProgressView *)progressView {
    return _progressHostView.progressView;
}

-(void)showPlayerControl:(UIGestureRecognizer*)recognizer {
    if(_playerControl.isControllerShown)
        [_playerControl hideController];
    else
        [_playerControl showController];
    return ;
}

-(void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    self.thePlayerLayer.frame = _assetsPlayerView.bounds;
    
    return ;
}

-(AVPlayer *)thePlayer {
    if(_thePlayer == nil) {
        _thePlayer = [AVPlayer playerWithPlayerItem:nil];
    }
    
    return _thePlayer;
}

-(AVPlayerLayer *)thePlayerLayer {
    if(_thePlayerLayer == nil)
        _thePlayerLayer = [AVPlayerLayer playerLayerWithPlayer:self.thePlayer];
    return _thePlayerLayer;
}

-(void)setMediaItem:(MPMediaItem *)mediaItem {
    _mediaItem = mediaItem;
    _mediaAsset = nil;
    
    [self.thePlayer pause];
    
    if(_previewImageView != nil) {
        _previewImageView.image = nil;
        _previewImageView.hidden = YES;
    }
    
    _assetsPlayerView.hidden = NO;
    AVAsset* audioAsset = [AVAsset assetWithURL:_mediaItem.assetURL];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:audioAsset];
        [self playVideoWithPlayerItem:playerItem];
    });
    
    return ;
}

-(void)setMediaAsset:(PHAsset *)mediaAsset {
    _mediaAsset = mediaAsset;
    _mediaItem = nil;
    
    [self.thePlayer pause];
    
    if(_mediaAsset.mediaType == PHAssetMediaTypeImage) {
        _previewImageView.hidden = NO;
        _assetsPlayerView.hidden = YES;
        [[MMPhotoManager sharedManager] requestOriginImageForAsset:_mediaAsset WhenComplete:^(NSData* imageData) {
            dispatch_async(dispatch_get_main_queue(), ^{
                _previewImageView.image = [UIImage imageWithData:imageData];
            });
        }];
    }else if(_mediaAsset.mediaType == PHAssetMediaTypeVideo) {
        if(_previewImageView != nil) {
            _previewImageView.image = nil;
            _previewImageView.hidden = YES;
        }
        
        _assetsPlayerView.hidden = NO;
        [[MMPhotoManager sharedManager] requestVideoForAsset:_mediaAsset WhenComplete:^(AVAsset* videoAsset) {
            dispatch_async(dispatch_get_main_queue(), ^{
                AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:videoAsset];
                [self playVideoWithPlayerItem:playerItem];
            });
        }];
    }
    
    return ;
}

-(void)playVideoWithPlayerItem:(AVPlayerItem *)playerItem {
    [self.thePlayer pause];
    [self.thePlayer replaceCurrentItemWithPlayerItem:playerItem];
    [self.thePlayer.currentItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
    
    return ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - KVO
-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if([keyPath isEqualToString:@"status"]) {
        if(self.thePlayer.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            [self.thePlayer.currentItem removeObserver:self forKeyPath:@"status"];
            self.playerControl.thePlayer = self.thePlayer;
        }else {
            [MMNotificationCenter postNotificationName:kMovieVideoPlayStateChangedNotification object:nil userInfo:@{@"status" : @(MMVideoPlayStatusFailed), @"error" : self.thePlayer.error}];
        }
    }
    
    return ;
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:_playerControl];
    if(CGRectContainsPoint(_playerControl.bounds, location))
        return NO;
    return YES;
}

#pragma mark - MMAssetPlayerControlDelegate
-(void)shouldPlayMediaAtControl:(MMAssetPlayerControl *)control {
    self.showProgress = YES;
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if(_mediaModifyViewController == nil)
            _mediaModifyViewController = (MMMediaModifyCollectionViewController*)[self.parentViewController.childViewControllers objectAtIndex:2];
        [_mediaModifyViewController prepareForPlay];
    });
    return ;
}

-(void)videoPlayerProgressUpdated:(NSTimeInterval)timeInterval {
    [_mediaModifyViewController updateProgress:timeInterval];
    return ;
}

-(void)control:(MMAssetPlayerControl *)control videoPlayModeChangedFrom:(MMVideoPlayMode)fromPlayMode to:(MMVideoPlayMode)toPlayMode {
    if(_dimBgView == nil) {
        _dimBgView = [[UIView alloc] initWithFrame:self.navigationController.view.bounds];
        _dimBgView.backgroundColor = [UIColor clearColor];
    }
    
    _isVideoPlaying = control.isPlaying;
    
    if(_isVideoPlaying == YES)
        [control pause];
    
    if(toPlayMode == MMVideoPlayModePictureInPicture && fromPlayMode == MMVideoPlayModeNormal) {
        [self.parentViewController.navigationController.view addSubview:_dimBgView];
        
        CGRect frameRect = [_assetsPlayerView convertRect:_assetsPlayerView.frame toView:_dimBgView];
        
        [_assetsPlayerView removeFromSuperview];
        [_dimBgView addSubview:_assetsPlayerView];
        [_assetsPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.trailing.mas_equalTo(_dimBgView);
            make.width.mas_equalTo(frameRect.size.width);
            make.height.mas_equalTo(frameRect.size.height);
        }];
        [_dimBgView addSubview:_assetsPlayerView];
        [_dimBgView layoutIfNeeded];
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [_assetsPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                make.bottom.and.trailing.mas_equalTo(_dimBgView);
                make.width.mas_equalTo(frameRect.size.width);
                make.height.mas_equalTo(frameRect.size.height);
            }];
            
            [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
                [_dimBgView layoutIfNeeded];
                self.thePlayerLayer.frame = _assetsPlayerView.bounds;
            } completion:^(BOOL finished) {
                if(finished && _isVideoPlaying == YES)
                    [control play];
            }];
        });
    }else if(toPlayMode == MMVideoPlayModeFullScreen && fromPlayMode == MMVideoPlayModePictureInPicture) {
        [_assetsPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.edges.mas_equalTo(_dimBgView);
        }];
        
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            [_dimBgView layoutIfNeeded];
            self.thePlayerLayer.frame = _assetsPlayerView.bounds;
        } completion:^(BOOL finished) {
            if(finished && _isVideoPlaying == YES)
                [control play];
        }];
    }else {        
        [_assetsPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.top.and.trailing.mas_equalTo(_dimBgView);
            make.width.mas_equalTo(self.view.bounds.size.width);
            make.height.mas_equalTo(self.view.bounds.size.height);
        }];
        
        [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
            [_dimBgView layoutIfNeeded];
            self.thePlayerLayer.frame = _assetsPlayerView.bounds;
        } completion:^(BOOL finished) {
            if(finished) {
                [_dimBgView removeFromSuperview];
                [self.view insertSubview:_assetsPlayerView belowSubview:_progressHostView];
                [_assetsPlayerView mas_remakeConstraints:^(MASConstraintMaker *make) {
                    make.edges.mas_equalTo(self.view);
                }];
                
                if(_isVideoPlaying == YES)
                    [control play];
            }
        }];
    }
    return ;
}

@end
