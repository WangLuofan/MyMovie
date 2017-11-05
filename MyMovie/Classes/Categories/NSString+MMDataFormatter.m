//
//  NSString+QHDataFormatter.m
//  GoldWorld
//
//  Created by 王落凡 on 2017/6/14.
//  Copyright © 2017年 qhspeed. All rights reserved.
//

#import "NSString+MMDataFormatter.h"

@implementation NSString (MMDataFormatter)

+(instancetype)stringWithStr:(NSString *)stringValue effectiveBits:(NSInteger)effectiveBits {
    CGFloat floatValue = [stringValue floatValue];
    NSString *str = [NSString stringWithFormat:@"%f",floatValue];
    NSArray *arrStr = [str componentsSeparatedByString:@"."];
    NSString *str1 = arrStr[1];
    NSString *str2 = arrStr[0];
    str1 = [str1 substringToIndex:effectiveBits];
    return [@[str2,str1] componentsJoinedByString:@"."];
}

+(instancetype)stringWithFloat:(CGFloat)floatValue effectiveBits:(NSInteger)effectiveBits {
    
    NSString* str = [NSString stringWithFormat:@"%f", floatValue];
    NSRange dotRange = [str rangeOfString:@"."];
    
    if(dotRange.location == NSNotFound) {
        str = [str stringByAppendingString:@"."];
        dotRange = [str rangeOfString:@"."];
    }
    
    for(int i = 0; i != effectiveBits; ++i)
        str = [str stringByAppendingString:@"0"];
    
    return [str substringWithRange:NSMakeRange(0, dotRange.location + dotRange.length + effectiveBits)];
}

+(instancetype)correctPrecisionWithString:(NSString *)number precision:(NSInteger)precision {
    if(precision == 0)
        return number;
    
    NSInteger pos = [number rangeOfString:@"."].location;
    NSMutableString* tmp = [number mutableCopy];
    
    if(pos == NSNotFound) {
        [tmp appendString:@"."];
        
        for(int i = 0; i != precision; ++i)
            [tmp appendString:@"0"];
    }else {
        if(number.length - pos - 1 > precision) {
            return [number substringToIndex:(pos + 1 + precision)];
        }
        
        NSInteger threshold = precision - (number.length - pos - 1);
        for(int i = 0; i < threshold; ++i)
            [tmp appendString:@"0"];
    }
    
    return tmp;
}

@end
