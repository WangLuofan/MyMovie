//
//  MMMediaPreviewViewController.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMBasicViewController.h"

@class PHAsset;
@class AVPlayerItem;
@interface MMMediaPreviewViewController : MMBasicViewController

@property(nonatomic, strong) PHAsset* mediaAsset;

-(void)playVideoWithPlayerItem:(AVPlayerItem*)playerItem;

@end
