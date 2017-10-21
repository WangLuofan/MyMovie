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

-(id)copyWithZone:(NSZone *)zone {
    MMMediaItemModel* tmpModel = [[[self class] alloc] init];
    
    tmpModel.mediaType = self.mediaType;
    tmpModel.duration = self.duration;
    
    return tmpModel;
}

@end

@implementation MMMediaVideoModel

-(id)copyWithZone:(NSZone *)zone {
    MMMediaVideoModel* tmpModel = [super copyWithZone:zone];
    
    tmpModel.mediaAsset = [self.mediaAsset copy];
    tmpModel.thumbnail = self.thumbnail;
    
    return tmpModel;
}

@end

@implementation MMMediaImageModel

-(id)copyWithZone:(NSZone *)zone {
    MMMediaImageModel* tmpModel = [super copyWithZone:zone];
    
    tmpModel.srcImage = [self.srcImage copy];
    tmpModel.duration = self.duration;
    tmpModel.thumbnail = self.thumbnail;
    
    return tmpModel;
}

@end

@implementation MMMediaAudioModel

-(id)copyWithZone:(NSZone *)zone {
    MMMediaAudioModel* tmpModel = [super copyWithZone:zone];
    
    tmpModel.title = [self.title copy];
    tmpModel.artist = [self.artist copy];
    tmpModel.mediaAsset = [self.mediaAsset copy];
    
    return tmpModel;
}

@end

@implementation MMMediaTransitionModel

-(id)copyWithZone:(NSZone *)zone {
    MMMediaTransitionModel* tmpModel = [super copyWithZone:zone];
    
    tmpModel.transitionType = self.transitionType;
    tmpModel.duration = self.duration;
    
    return tmpModel;
}

@end
