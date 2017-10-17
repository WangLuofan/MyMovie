//
//  MMHudUtils.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/17.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMHUDUtils.h"

@interface MMHUDUtils()

@end

@implementation MMHUDUtils

+(void)showHUDInView:(UIView *)view {
    return [MMHUDUtils showHUDInView:view inMode:MBProgressHUDModeIndeterminate];
}

+(void)showHUDInView:(UIView *)view inMode:(MBProgressHUDMode)mode {
    return [MMHUDUtils showHUDInView:view inMode:mode withTitle:nil];
}

+(void)showHUDInView:(UIView *)view inMode:(MBProgressHUDMode)mode withTitle:(NSString *)title {
    MBProgressHUD* HUD = [[MBProgressHUD alloc] initWithView:view];
    HUD.mode = mode;
    HUD.label.text = title;
    HUD.removeFromSuperViewOnHide = YES;
    
    [view addSubview:HUD];
    [HUD showAnimated:YES];
    return ;
}

+(void)hideHUDForView:(UIView *)view {
    return [MMHUDUtils hideHUDForView:view complete:nil];
}

+(void)hideHUDForView:(UIView *)view complete:(void (^)(void))complete {
    MBProgressHUD* hud = [MBProgressHUD HUDForView:view];
    if(hud != nil) {
        if(complete != nil)
            hud.completionBlock = complete;
        [hud hideAnimated:YES];
    }
    return ;
}

@end
