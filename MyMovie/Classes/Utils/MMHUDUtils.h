//
//  MMHudUtils.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/17.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <MBProgressHUD.h>
#import <Foundation/Foundation.h>

@interface MMHUDUtils : NSObject

+(void)showHUDInView:(UIView*)view;
+(void)showHUDInView:(UIView *)view inMode:(MBProgressHUDMode)mode;
+(void)showHUDInView:(UIView *)view inMode:(MBProgressHUDMode)mode withTitle:(NSString*)title;
+(void)hideHUDForView:(UIView*)view;
+(void)hideHUDForView:(UIView *)view complete:(void(^)(void))complete;

@end
