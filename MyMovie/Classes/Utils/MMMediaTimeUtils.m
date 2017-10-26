//
//  MMMediaTimeUtils.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/26.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMMediaTimeUtils.h"

@implementation MMMediaTimeUtils

+(NSString*)convertTimeIntervalToTime:(NSTimeInterval)timeInterval {
    NSInteger hour = (NSInteger)(timeInterval / 3600);
    NSInteger minute = (NSInteger)(timeInterval / 60);
    NSInteger second = (NSInteger)(timeInterval - hour * 3600 - minute * 60);
    
    NSString* timeStr = @"";
    
    if(hour != 0)
        timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@"%02ld", (long)hour]];
    
    if(hour != 0)
        timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@":%02ld", minute]];
    else
        timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@"%02ld", minute]];
    
    if(second == 0) second += 1;
    timeStr = [timeStr stringByAppendingString:[NSString stringWithFormat:@":%02ld", second]];
    
    return timeStr;
}

@end
