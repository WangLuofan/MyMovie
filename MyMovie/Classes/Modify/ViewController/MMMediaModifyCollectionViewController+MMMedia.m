//
//  MMMediaModifyCollectionViewController+MMMedia.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/29.
//  Copyright © 2017年 王落凡. All rights reserved.
//
#import <AVFoundation/AVFoundation.h>
#import <CoreMedia/CoreMedia.h>
#import "MMAssetPlayerProgressView.h"
#import "MMMediaItemModel.h"
#import "MMPhotoManager.h"
#import "MMAudioMixModel.h"
#import "MMMediaPreviewViewController.h"
#import "MMMediaModifyCollectionViewController+MMMedia.h"

#define k1280pSize CGSizeMake(1280.0f, 720.0f)
@implementation MMMediaModifyCollectionViewController (MMMedia)

-(NSURL*)tempFileURLForModel:(MMMediaItemModel*)model {
    NSString* filePath = [[self docPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", model.identifer]];
    
    return [NSURL fileURLWithPath:filePath];
}

-(NSString*)docPath {
    return [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:self.parentViewController.title];
}

-(void)videoFromImageModel:(MMMediaImageModel *)model onQueue:(dispatch_queue_t)queue complete:(void (^)(NSString *))complete {
    NSURL* fileURL = [self tempFileURLForModel:model];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:fileURL.path])
        [[NSFileManager defaultManager] removeItemAtPath:fileURL.path error:nil];
    
    NSDictionary* attrDict = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA), (id)kCVPixelBufferWidthKey : @(k1280pSize.width), (id)kCVPixelBufferHeightKey : @(k1280pSize.height), (id)kCVPixelBufferOpenGLCompatibilityKey : (id)kCFBooleanTrue, (id)kCVPixelBufferCGBitmapContextCompatibilityKey : (id)kCFBooleanTrue};
    
    __block AVAssetWriter* assetWriter = [AVAssetWriter assetWriterWithURL:fileURL fileType:AVFileTypeMPEG4 error:nil];
    
    __block AVAssetWriterInput* assetWriterInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:@{AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : [NSNumber numberWithDouble:k1280pSize.width], AVVideoHeightKey : [NSNumber numberWithDouble:k1280pSize.height]}];
    assetWriterInput.expectsMediaDataInRealTime = NO;
    
    __block AVAssetWriterInputPixelBufferAdaptor* adaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:assetWriterInput sourcePixelBufferAttributes:attrDict];
    
    __block CMTime nextPTS = kCMTimeZero;
    NSInteger totalFrame = (int)(model.duration * 30);
    
    if([assetWriter canAddInput:assetWriterInput] == YES) {
        [assetWriter addInput:assetWriterInput];
        
        while([assetWriter startWriting] == NO) ;
        
        [assetWriter startSessionAtSourceTime:kCMTimeZero];
        __block NSInteger frameCount = 0;
        
        CVPixelBufferRef pixelBuf = [self imageToPixelBufferRef:[UIImage imageWithData:model.srcImage]];
        [assetWriterInput requestMediaDataWhenReadyOnQueue:queue usingBlock:^{
            while(assetWriterInput.readyForMoreMediaData == YES) {
                if([adaptor appendPixelBuffer:pixelBuf withPresentationTime:nextPTS]) {
                    nextPTS = CMTimeAdd(nextPTS, CMTimeMake(1, 30));
                    ++frameCount;
                    if(frameCount == totalFrame) {
                        [assetWriterInput markAsFinished];
                        [assetWriter finishWritingWithCompletionHandler:^{
                            if(assetWriter.status == AVAssetWriterStatusCompleted) {
                                
                                adaptor = nil;
                                assetWriterInput = nil;
                                assetWriter = nil;
                                
                                if(complete) {
                                    complete(fileURL.path);
                                }
                            }else if(assetWriter.status == AVAssetWriterStatusFailed) {
                                NSLog(@"%@", assetWriter.error);
                            }
                        }];
                    }
                }else if(assetWriter.status == AVAssetWriterStatusFailed) {
                    NSLog(@"%@", assetWriter.error);
                    break;
                }
            }
        }];
    }
    
    return ;
}

-(CVPixelBufferRef)imageToPixelBufferRef:(UIImage*)image {
    NSDictionary* attrDict = @{(id)kCVPixelBufferOpenGLCompatibilityKey : (id)kCFBooleanTrue, (id)kCVPixelBufferCGBitmapContextCompatibilityKey : (id)kCFBooleanTrue, (id)kCVPixelBufferWidthKey : @(k1280pSize.width), (id)kCVPixelBufferHeightKey : @(k1280pSize.height), (id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA)};
    
    CVPixelBufferRef pixelBuf;
    CVReturn err = CVPixelBufferCreate(kCFAllocatorDefault, k1280pSize.width, k1280pSize.height, kCVPixelFormatType_32BGRA, (__bridge CFDictionaryRef)attrDict, &pixelBuf);
    
    if(err == kCVReturnSuccess) {
        if(CVPixelBufferLockBaseAddress(pixelBuf, 0) == kCVReturnSuccess) {
            void* baseAddr = CVPixelBufferGetBaseAddress(pixelBuf);
            
            CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
            CGContextRef context = CGBitmapContextCreate(baseAddr, k1280pSize.width, k1280pSize.height, 8, CVPixelBufferGetBytesPerRow(pixelBuf), colorSpace, kCGImageAlphaNoneSkipFirst | kCGBitmapByteOrder32Host);
            CGContextDrawImage(context, AVMakeRectWithAspectRatioInsideRect(image.size, CGRectMake(0, 0, k1280pSize.width, k1280pSize.height)), image.CGImage);
            CGColorSpaceRelease(colorSpace);
            CGContextRelease(context);
        }
        
        CVPixelBufferUnlockBaseAddress(pixelBuf, 0);
    }
    
    return pixelBuf;
}

-(void)compositionWithVideoAssetsArray:(NSArray *)videoAssetsArray audioAssets:(NSArray *)audioAssetsArray complete:(void (^)(AVPlayerItem *))complete {
    
    AVMutableComposition* composition = [AVMutableComposition composition];
    AVMutableCompositionTrack* videoTrack_1 = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    AVMutableCompositionTrack* videoTrack_2 = [composition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    AVMutableCompositionTrack* audioTrack = [composition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    NSArray* videoTracks = @[videoTrack_1, videoTrack_2];
    __block AVAudioMix* audioMix = nil;
    
    dispatch_group_t buildGroup = dispatch_group_create();
    dispatch_group_async(buildGroup, dispatch_queue_create("com.mmovie.videoTrack.build.queue", NULL), ^{
        [self buildVideoTracks:videoTracks];
    });
    dispatch_group_async(buildGroup, dispatch_queue_create("com.mmovie.audioTrack.build.queue", NULL), ^{
        audioMix = [self buildAudioTracks:audioTrack];
    });
    
    dispatch_group_notify(buildGroup, dispatch_get_main_queue(), ^{
        
        AVMutableVideoComposition* videoComposition = [AVMutableVideoComposition videoCompositionWithPropertiesOfAsset:composition];
        [self transitionInstructionsInVideoComposition:videoComposition videoAssets:videoAssetsArray];
        
        AVPlayerItem* playerItem = [AVPlayerItem playerItemWithAsset:composition];
        playerItem.videoComposition = videoComposition;
        playerItem.audioMix = audioMix;
        
        if(complete) {
            self.previewViewController.progressView.progress = 1.0f;
            CMTimeShow(playerItem.duration);
            complete(playerItem);
        }
        
        return ;
    });
    
    return ;
}

-(void)transitionInstructionsInVideoComposition:(AVVideoComposition*)videoComposition videoAssets:(NSArray*)videoAssets {
    
    NSUInteger idx = 1;
    
    int layIndex = 0;
    for (AVMutableVideoCompositionInstruction* vci in videoComposition.instructions) {
        if(vci.layerInstructions.count == 2) {
            MMMediaTransitionModel* transtionModel = [videoAssets objectAtIndex:idx];
            AVMutableVideoCompositionLayerInstruction* fromLayerInstruction = (AVMutableVideoCompositionLayerInstruction *)[vci.layerInstructions objectAtIndex:layIndex];
            AVMutableVideoCompositionLayerInstruction* toLayerInstruction = (AVMutableVideoCompositionLayerInstruction *)[vci.layerInstructions objectAtIndex:1 - layIndex];
            layIndex = 1 - layIndex;
            
            CMTimeRange timeRange = vci.timeRange;
            if (transtionModel.transitionType == TransitionTypeOpacity) {
                
                [fromLayerInstruction setOpacityRampFromStartOpacity:1.0
                                                        toEndOpacity:0.0
                                                           timeRange:timeRange];
            }
            
            if (transtionModel.transitionType == TransitionTypePush) {
                
                // Define starting and ending transforms                        // 1
                CGAffineTransform identityTransform = CGAffineTransformIdentity;
                
                CGFloat videoWidth = videoComposition.renderSize.width;
                
                CGAffineTransform fromDestTransform =                           // 2
                CGAffineTransformMakeTranslation(-videoWidth, 0.0);
                
                CGAffineTransform toStartTransform =
                CGAffineTransformMakeTranslation(videoWidth, 0.0);
                
                [fromLayerInstruction setTransformRampFromStartTransform:identityTransform // 3
                                                          toEndTransform:fromDestTransform
                                                               timeRange:timeRange];
                
                [toLayerInstruction setTransformRampFromStartTransform:toStartTransform    // 4
                                                        toEndTransform:identityTransform
                                                             timeRange:timeRange];
            }
            
            if (transtionModel.transitionType == TransitionTypeCrop) {
                
                CGFloat videoWidth = videoComposition.renderSize.width;
                CGFloat videoHeight = videoComposition.renderSize.height;
                
                CGRect startRect = CGRectMake(0.0f, 0.0f, videoWidth, videoHeight);
                CGRect endRect = CGRectMake(0.0f, videoHeight, videoWidth, 0.0f);
                
                [fromLayerInstruction setCropRectangleRampFromStartCropRectangle:startRect toEndCropRectangle:endRect timeRange:timeRange];
                [toLayerInstruction setCropRectangleRampFromStartCropRectangle:CGRectMake(0.0f, 0.0f, videoWidth, 0.0f) toEndCropRectangle:CGRectMake(0.0f, 0.0f, videoWidth, videoHeight) timeRange:timeRange];
            }
            
            vci.layerInstructions = @[fromLayerInstruction, toLayerInstruction];
            idx += 2;
        }
    }
    
    return ;
}

-(void)buildVideoTracks:(NSArray*)videoTracks {
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    
    __block NSInteger trackIndex = 0;
    __block CMTime cursorTime = kCMTimeZero;
    
    for(int i = 0; ; i += 2) {
        dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        
        if(i > self.assetsDataSource.count) {
            dispatch_semaphore_signal(semaphore);
            break;
        }
        
        MMMediaItemModel* itemModel = [self.assetsDataSource objectAtIndex:i];
        if(itemModel.mediaType == MMAssetMediaTypeImage) {
            NSString* filePath = [[self docPath] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.mp4", itemModel.identifer]];
            
            AVAsset* imgAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:filePath]];
            [imgAsset loadValuesAsynchronouslyForKeys:@[@"duration", @"tracks"] completionHandler:^{
                if([imgAsset statusOfValueForKey:@"duration" error:nil] == AVKeyValueStatusLoaded && [imgAsset statusOfValueForKey:@"tracks" error:nil] == AVKeyValueStatusLoaded) {
                    AVMutableCompositionTrack* track = [videoTracks objectAtIndex:(trackIndex++ % 2)];
                    
                    if(i != 0) {
                        MMMediaTransitionModel* transitionModel = (MMMediaTransitionModel*)[self.assetsDataSource objectAtIndex:i - 1];
                        if(transitionModel.transitionType != TransitionTypeNone)
                            cursorTime = CMTimeSubtract(cursorTime, CMTimeMake(transitionModel.duration * 2, 2));
                    }
                    
                    [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, imgAsset.duration) ofTrack:[[imgAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:cursorTime error:nil];
                    
                    cursorTime = CMTimeAdd(cursorTime, imgAsset.duration);
                    self.previewViewController.progressView.progress += 0.05;
                    dispatch_semaphore_signal(semaphore);
                }
            }];
        }else if(itemModel.mediaType == MMAssetMediaTypeVideo) {
            AVMutableCompositionTrack* track = [videoTracks objectAtIndex:(trackIndex++ % 2)];
            AVAsset* videoAsset = ((MMMediaVideoModel*)itemModel).mediaAsset;
            
            CMTimeShow(videoAsset.duration);
            CMTime assetDuration = CMTimeMakeWithSeconds(((MMMediaVideoModel*)itemModel).duration, ((MMMediaVideoModel*)itemModel).mediaAsset.duration.timescale);
            if(i != 0) {
                MMMediaTransitionModel* transitionModel = (MMMediaTransitionModel*)[self.assetsDataSource objectAtIndex:i - 1];
                if(transitionModel.transitionType != TransitionTypeNone)
                    cursorTime = CMTimeSubtract(cursorTime, CMTimeMake(transitionModel.duration * 2, 2));
            }
            
            while(CMTIME_COMPARE_INLINE(assetDuration, >=, videoAsset.duration)) {
                [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, videoAsset.duration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:cursorTime error:nil];
                cursorTime = CMTimeAdd(cursorTime, videoAsset.duration);
                assetDuration = CMTimeSubtract(assetDuration, videoAsset.duration);
            }
            
            if(CMTIME_COMPARE_INLINE(assetDuration, !=, kCMTimeZero)) {
                [track insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetDuration) ofTrack:[[videoAsset tracksWithMediaType:AVMediaTypeVideo] firstObject] atTime:cursorTime error:nil];
                cursorTime = CMTimeAdd(cursorTime, assetDuration);
            }
            
            self.previewViewController.progressView.progress += 0.05f;
            dispatch_semaphore_signal(semaphore);
        }
    }
    return ;
}

-(AVAudioMix*)buildAudioTracks:(AVMutableCompositionTrack*)audioTrack {
    CMTime cursorTime = kCMTimeZero;
    CMTime audioDurTime = kCMTimeZero, audioStartTime = kCMTimeZero;
    
    AVMutableAudioMix* audioMix = [AVMutableAudioMix audioMix];
    AVMutableAudioMixInputParameters* inputParams = [AVMutableAudioMixInputParameters audioMixInputParametersWithTrack:audioTrack];
    for (MMMediaAudioModel* audioModel in self.audioDataSource) {
        CMTime assetDuration = CMTimeMakeWithSeconds(audioModel.duration, audioModel.mediaAsset.duration.timescale);
        
        while(CMTIME_COMPARE_INLINE(assetDuration, >=, audioModel.mediaAsset.duration)) {
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, audioModel.mediaAsset.duration) ofTrack:[[audioModel.mediaAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:cursorTime error:nil];
            
            cursorTime = CMTimeAdd(cursorTime, audioModel.mediaAsset.duration);
            assetDuration = CMTimeSubtract(assetDuration, audioModel.mediaAsset.duration);
        }
        
        if(CMTIME_COMPARE_INLINE(assetDuration, !=, kCMTimeZero)) {
            [audioTrack insertTimeRange:CMTimeRangeMake(kCMTimeZero, assetDuration) ofTrack:[[audioModel.mediaAsset tracksWithMediaType:AVMediaTypeAudio] firstObject] atTime:cursorTime error:nil];
            cursorTime = CMTimeAdd(cursorTime, assetDuration);
        }
        
        CGFloat startVolume = 0.0f;
        CMTime audioTime = kCMTimeZero;
        for (MMAudioMixModel* audioMixModel in audioModel.inputParams) {
            audioTime = CMTimeSubtract(CMTimeMakeWithSeconds(audioMixModel.timeInterval, audioModel.mediaAsset.duration.timescale), audioTime);
            [inputParams setVolumeRampFromStartVolume:startVolume toEndVolume:audioMixModel.audioLevel timeRange:CMTimeRangeMake(audioDurTime, audioTime)];
            
            startVolume = audioMixModel.audioLevel;
            audioDurTime = CMTimeAdd(audioDurTime, audioTime);
            audioTime = CMTimeMakeWithSeconds(audioMixModel.timeInterval, audioModel.mediaAsset.duration.timescale);
        }
        
        audioStartTime = CMTimeAdd(audioStartTime, assetDuration);
        audioDurTime = audioStartTime;
    }
    
    audioMix.inputParameters = @[inputParams];
    return audioMix;
}

@end
