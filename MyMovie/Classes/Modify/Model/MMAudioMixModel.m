//
//  MMAudioMixModel.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/31.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMAudioMixModel.h"

@implementation MMAudioMixModel

-(id)copyWithZone:(NSZone *)zone {
    MMAudioMixModel* tmpModel = [[MMAudioMixModel alloc] init];
    
    tmpModel.startTimeRange = self.startTimeRange;
    tmpModel.endTimeRange = self.endTimeRange;
    tmpModel.audioLevel = self.audioLevel;
    
    return tmpModel;
}

@end
