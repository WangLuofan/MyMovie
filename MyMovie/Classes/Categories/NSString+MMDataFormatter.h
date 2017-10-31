//
//  NSString+QHDataFormatter.h
//  GoldWorld
//
//  Created by 王落凡 on 2017/6/14.
//  Copyright © 2017年 qhspeed. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (MMDataFormatter)

+(instancetype)stringWithFloat:(CGFloat)floatValue effectiveBits:(NSInteger)effectiveBits;
+(instancetype)stringWithStr:(NSString *)stringValue effectiveBits:(NSInteger)effectiveBits;

+(instancetype)correctPrecisionWithString:(NSString*)number precision:(NSInteger)precision;

@end
