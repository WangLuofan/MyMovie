//
//  MMAssetPlayerControl.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/26.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AVPlayer;
@interface MMAssetPlayerControl : UIView

@property(nonatomic, weak) AVPlayer* thePlayer;
@property(nonatomic, readonly) BOOL isControllerShown;

-(void)showController;
-(void)hideController;

@end
