//
//  UIView+MMRener.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/26.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "UIView+MMRender.h"

@implementation UIView (MMRender)

-(UIImage*)toImage {
    UIGraphicsBeginImageContext(self.bounds.size);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return img;
}

@end
