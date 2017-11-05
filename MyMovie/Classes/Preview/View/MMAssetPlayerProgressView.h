//
//  MMAssetPlayerProgressView.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/28.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMAssetPlayerProgressView;
@interface MMAssetPlayerProgressHostView : UIView

@property(nonatomic, strong) MMAssetPlayerProgressView* progressView;

@end

@interface MMAssetPlayerProgressView : UIImageView

@property(nonatomic, assign) CGFloat progress;

@end
