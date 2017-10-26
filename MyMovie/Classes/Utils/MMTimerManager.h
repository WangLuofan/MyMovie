//
//  MMTimerManager.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/26.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMTimerManager : NSObject

+(instancetype)sharedManager;

-(NSTimer*)addTimerWithTimeInterval:(NSTimeInterval)timeInterval repeats:(BOOL)repeats target:(id)target selector:(SEL)selector;
-(void)removeTimer:(NSTimer*)timer;
-(void)removeAllTimers;

@end
