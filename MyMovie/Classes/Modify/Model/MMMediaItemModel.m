//
//  MMMediaItemModel.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/19.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MMMediaItemModel.h"

@implementation MMMediaItemModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _modified = YES;
    }
    return self;
}

@end

@implementation MMMediaVideoModel

@end

@implementation MMMediaImageModel

@end

@implementation MMMediaAudioModel

- (instancetype)init
{
    self = [super init];
    if (self) {
        _inputParams = [NSMutableArray array];
    }
    return self;
}

@end

@implementation MMMediaTransitionModel

@end
