//
//  MMTimerManager.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/26.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMTimerManager.h"

@interface MMTimerManager()

@property(nonatomic, strong) NSMutableArray* timerArray;

@end

static MMTimerManager* _obj;
@implementation MMTimerManager

- (instancetype)init
{
    self = [super init];
    if (self) {
        _timerArray = [NSMutableArray array];
    }
    return self;
}

+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _obj = [[MMTimerManager alloc] init];
    });
    
    return _obj;
}

-(__weak NSTimer *)addTimerWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats target:(id)target selector:(SEL)selector {
    NSTimer* timer = [NSTimer timerWithTimeInterval:timeInterval target:target selector:selector userInfo:nil repeats:repeats];
    [_timerArray addObject:timer];
    
    return timer;
}

-(void)removeTimer:(NSTimer *)timer {
    if([_timerArray containsObject:timer]) {
        [timer invalidate];
        [_timerArray removeObject:timer];
        
        timer = nil;
    }
    
    return ;
}

-(void)removeAllTimers {
    for (__strong NSTimer* timer in _timerArray) {
        [timer invalidate];
        [_timerArray removeObject:timer];
        
        timer = nil;
    }
    return ;
}

@end
