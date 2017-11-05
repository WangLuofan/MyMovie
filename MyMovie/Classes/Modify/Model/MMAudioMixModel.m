//
//  MMAudioMixModel.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/31.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMAudioMixModel.h"

@implementation MMAudioMixModel

- (instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval audio:(CGFloat)audio
{
    self = [super init];
    if (self) {
        _timeInterval = timeInterval;
        _audioLevel = audio;
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"timeInterval: %.2lf, audio: %.1lf", self.timeInterval, self.audioLevel];
}

-(id)copyWithZone:(NSZone *)zone {
    MMAudioMixModel* tmpModel = [[MMAudioMixModel alloc] init];
    
    tmpModel.timeInterval = self.timeInterval;
    tmpModel.audioLevel = self.audioLevel;
    
    return tmpModel;
}

@end
