//
//  UIImage+MMImage.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/26.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "UIImage+MMImage.h"

@implementation UIImage (MMImage)

+(instancetype)imageNamed:(NSString *)imageName scale:(CGFloat)scale {
    UIImage* image = [UIImage imageNamed:imageName];
    
    CGSize imgSize = CGSizeMake(image.size.width * scale, image.size.height * scale);
    UIGraphicsBeginImageContext(imgSize);
    [image drawInRect:CGRectMake(0, 0, imgSize.width, imgSize.height)];
    
    image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
