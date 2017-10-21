//
//  MMMediaPreviewViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPhotoManager.h"
#import <AVFoundation/AVFoundation.h>
#import "MMMediaPreviewViewController.h"

@interface MMMediaPreviewViewController ()

//Image
@property(nonatomic, strong) UIImageView* previewImageView;

//Video
@property(nonatomic, strong) AVPlayer* thePlayer;
@property(nonatomic, strong) AVPlayerLayer* thePlayerLayer;

@end

@implementation MMMediaPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    return ;
}

-(void)setMediaAsset:(PHAsset *)mediaAsset {
    _mediaAsset = mediaAsset;
    
    if(_thePlayer != nil) {
        [_thePlayer pause];
        if(_thePlayerLayer != nil) _thePlayerLayer.hidden = YES;
    }
    
    if(_mediaAsset.mediaType == PHAssetMediaTypeImage) {
        if(_previewImageView == nil) {
            _previewImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
            _previewImageView.contentMode = UIViewContentModeScaleAspectFill;
            [self.view addSubview:_previewImageView];
        }
        
        _previewImageView.hidden = NO;
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
        
        if(_thePlayer == nil) {
            _thePlayer = [AVPlayer playerWithPlayerItem:nil];
            _thePlayerLayer = [AVPlayerLayer playerLayerWithPlayer:_thePlayer];
            _thePlayerLayer.frame = self.view.bounds;
            [self.view.layer addSublayer:_thePlayerLayer];
        }
        
        _thePlayerLayer.hidden = NO;
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
    [_thePlayer pause];
    [_thePlayer replaceCurrentItemWithPlayerItem:playerItem];
    
    [_thePlayer play];
    return ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
