//
//  MMAudioMixModel.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/31.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMAudioMixModel.h"

@implementation MMAudioMixModel
@dynamic supportsSecureCoding;

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

+(BOOL)supportsSecureCoding {
    return YES;
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeDouble:_timeInterval forKey:@"TimeInterval"];
    [aCoder encodeFloat:_audioLevel forKey:@"AudioLevel"];
    return ;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super init];
    
    if(self) {
        _timeInterval = [aDecoder decodeDoubleForKey:@"TimeInterval"];
        _audioLevel = [aDecoder decodeFloatForKey:@"AudioLevel"];
    }
    
    return self;
}

@end
