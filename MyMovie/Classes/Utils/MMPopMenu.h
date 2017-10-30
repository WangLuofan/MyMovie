//
//  MMPopMenu.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/30.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMPopMenu : UIViewController

@property(nonatomic, assign) BOOL isMenuShown;

+(instancetype)menuWithItems:(NSArray<NSString*> *)items tracks:(NSUInteger)tracks;
-(void)showInView:(UIView*)inView orientation:(UIInterfaceOrientation)orientation;
-(void)hideMenu;

@end
