//
//  UIViewController+MMRender.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/26.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (MMRender)

-(UIImageView*)renderItemAtPosition:(CGPoint)point;
-(NSIndexPath*)getItemIndexPathAtPoint:(CGPoint)point;
-(CGRect)itemFrameAtPosition:(CGPoint)point toView:(UIView*)view;

@end
