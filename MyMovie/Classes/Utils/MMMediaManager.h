//
//  MMMediaManager.h
//  MyMovie
//
//  Created by 王落凡 on 2017/11/12.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <MediaPlayer/MediaPlayer.h>

@interface MMMediaManager : NSObject

@property(nonatomic, assign) MPMediaLibraryAuthorizationStatus authorizationStatus;

+(instancetype)sharedManager;
-(NSArray*)allMedias;
-(NSArray*)queryMediasWithTitle:(NSString*)title;
-(NSArray*)queryMediasWithArtist:(NSString*)artist;
-(MPMediaItem*)queryMediaItemWithTitle:(NSString*)title artist:(NSString*)artist;
-(void)requestMediaQueryAuthorizationWhenComplete:(void(^)(MPMediaLibraryAuthorizationStatus))completeHandler;

@end
