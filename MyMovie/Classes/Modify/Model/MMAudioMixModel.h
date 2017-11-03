//
//  MMAudioMixModel.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/31.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMAudioMixModel : NSObject

-(instancetype)initWithTimeInterval:(NSTimeInterval)timeInterval audio:(CGFloat)audio;

@property(nonatomic, assign) NSTimeInterval timeInterval;
@property(nonatomic, assign) CGFloat audioLevel;

@end
