//
//  MMMediaItemModel.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/19.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, TransitionType) {
    TransitionTypeNone,
    TransitionTypePush,
    TransitionTypeOpacity,
    TransitionTypeCrop,
};

@class AVAsset;
@interface MMMediaItemModel : NSObject <NSSecureCoding>

@property(nonatomic, assign) NSUInteger mediaType;
@property(nonatomic, assign) NSTimeInterval duration;
@property(nonatomic, copy) NSString* identifer;
@property(nonatomic, assign) BOOL modified;

@end

@interface MMMediaVideoModel : MMMediaItemModel

@property(nonatomic, copy) AVAsset* mediaAsset;
@property(nonatomic, strong) UIImage* thumbnail;

@end

@interface MMMediaImageModel : MMMediaItemModel

@property(nonatomic, copy) NSData* srcImage;
@property(nonatomic, strong) UIImage* thumbnail;

@end

@interface MMMediaAudioModel : MMMediaItemModel

@property(nonatomic, copy) NSString* title;
@property(nonatomic, copy) NSString* artist;
@property(nonatomic, copy) AVAsset* mediaAsset;
@property(nonatomic, strong) NSMutableArray* inputParams;

@end

@interface MMMediaTransitionModel : MMMediaItemModel

@property(nonatomic, assign) TransitionType transitionType;

@end
