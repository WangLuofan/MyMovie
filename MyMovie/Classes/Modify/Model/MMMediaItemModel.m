//
//  MMMediaItemModel.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/19.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "MMMediaItemModel.h"
#import "MMAudioMixModel.h"
#import "MMMediaManager.h"

@implementation MMMediaItemModel
@dynamic supportsSecureCoding;

- (instancetype)init
{
    self = [super init];
    if (self) {
        _modified = YES;
    }
    return self;
}

+(BOOL)supportsSecureCoding {
    return YES;
}

- (void)encodeWithCoder:(nonnull NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:_mediaType] forKey:@"MediaType"];
    [aCoder encodeDouble:_duration forKey:@"Duration"];
    [aCoder encodeObject:_identifer forKey:@"Identifier"];
    [aCoder encodeBool:_modified forKey:@"Modified"];
    
    return ;
}

- (instancetype)initWithCoder:(nonnull NSCoder *)aDecoder {
    self = [super init];
    
    if(self) {
        _mediaType = [[aDecoder decodeObjectForKey:@"MediaType"] unsignedIntegerValue];
        _duration = [aDecoder decodeDoubleForKey:@"Duration"];
        _identifer = [aDecoder decodeObjectForKey:@"Identifier"];
        _modified = [aDecoder decodeBoolForKey:@"Modified"];
    }
    
    return self;
}

@end

@implementation MMMediaVideoModel

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:UIImageJPEGRepresentation(_thumbnail, 0.8f) forKey:@"Thumbnail"];
    [aCoder encodeObject:((AVURLAsset*)_mediaAsset).URL forKey:@"MediaAsset"];
    return ;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if(self) {
        _thumbnail = [UIImage imageWithData:[aDecoder decodeObjectForKey:@"Thumbnail"]];
        _mediaAsset = [AVAsset assetWithURL:[aDecoder decodeObjectForKey:@"MediaAsset"]];
        
        NSArray* keys = @[@"commonMetadata", @"duration", @"tracks"];
        [_mediaAsset loadValuesAsynchronouslyForKeys:keys completionHandler:nil];
    }
    
    return self;
}

@end

@implementation MMMediaImageModel

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:_srcImage forKey:@"SrcImage"];
    [aCoder encodeObject:UIImageJPEGRepresentation(_thumbnail, 0.8f) forKey:@"Thumbnail"];
    return ;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if(self) {
        _srcImage = [aDecoder decodeObjectForKey:@"SrcImage"];
        _thumbnail = [UIImage imageWithData:[aDecoder decodeObjectForKey:@"Thumbnail"]];
    }
    
    return self;
}

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

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:_title forKey:@"Title"];
    [aCoder encodeObject:_artist forKey:@"Artist"];
    [aCoder encodeObject:((AVURLAsset*)_mediaAsset).URL forKey:@"MediaAsset"];
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:_audioSourceType] forKey:@"AudioSourceType"];
    
    [aCoder encodeInteger:_inputParams.count forKey:@"AudioMixCount"];
    
    for(int i = 0; i != _inputParams.count; ++i) {
        MMAudioMixModel* audioMixModel = (MMAudioMixModel*)[_inputParams objectAtIndex:i];
        NSString* timeIntervalKey = [NSString stringWithFormat:@"audio_timeInterval_%d", i];
        NSString* audioLevelKey = [NSString stringWithFormat:@"audio_level_%d", i];
        
        [aCoder encodeDouble:audioMixModel.timeInterval forKey:timeIntervalKey];
        [aCoder encodeDouble:audioMixModel.audioLevel forKey:audioLevelKey];
    }
    
    return ;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if(self) {
        _title = [aDecoder decodeObjectForKey:@"Title"];
        _artist = [aDecoder decodeObjectForKey:@"Artist"];
        _audioSourceType = (AudioSourceType)[[aDecoder decodeObjectForKey:@"AudioSourceType"] unsignedIntegerValue];
        
        NSArray* keys = @[@"commonMetadata", @"duration", @"tracks"];
        if(_audioSourceType == AudioMusicPodSourceType) {
            MPMediaItem* mediaItem = [[MMMediaManager sharedManager] queryMediaItemWithTitle:_title artist:_artist];
            
            _mediaAsset = [AVAsset assetWithURL:mediaItem.assetURL];
            [_mediaAsset loadValuesAsynchronouslyForKeys:keys completionHandler:nil];
            
            _inputParams = [NSMutableArray array];
            
            NSInteger audioMixCount = [aDecoder decodeIntegerForKey:@"AudioMixCount"];
            for(int i = 0; i != audioMixCount; ++i) {
                NSString* timeIntervalKey = [NSString stringWithFormat:@"audio_timeInterval_%d", i];
                NSString* audioLevelKey = [NSString stringWithFormat:@"audio_level_%d", i];
                
                NSTimeInterval timeInterval = [aDecoder decodeDoubleForKey:timeIntervalKey];
                CGFloat audioLevel = [aDecoder decodeDoubleForKey:audioLevelKey];
                
                MMAudioMixModel* audioMixModel = [[MMAudioMixModel alloc] initWithTimeInterval:timeInterval audio:audioLevel];
                [_inputParams addObject:audioMixModel];
            }
        }else {
            NSURL* assetsURL = (NSURL*)[aDecoder decodeObjectForKey:@"MediaAsset"];
            
            if(assetsURL != nil) {
                _mediaAsset = [AVAsset assetWithURL:assetsURL];
                [_mediaAsset loadValuesAsynchronouslyForKeys:keys completionHandler:nil];
            }
        }
    }
    
    return self;
}

@end

@implementation MMMediaTransitionModel

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [super encodeWithCoder:aCoder];
    
    [aCoder encodeObject:[NSNumber numberWithUnsignedInteger:_transitionType] forKey:@"TransitionType"];
    return ;
}

-(instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    
    if(self) {
        _transitionType = [[aDecoder decodeObjectForKey:@"TransitionType"] unsignedIntegerValue];
    }
    
    return self;
}

@end
