//
//  MMAudioMixModel.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/31.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMAudioMixModel : NSObject

@property(nonatomic, assign) NSTimeInterval startTimeRange;
@property(nonatomic, assign) NSTimeInterval endTimeRange;
@property(nonatomic, assign) CGFloat audioLevel;

@end
