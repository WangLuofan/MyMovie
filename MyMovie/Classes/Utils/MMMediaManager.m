//
//  MMMediaManager.m
//  MyMovie
//
//  Created by 王落凡 on 2017/11/12.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMMediaManager.h"

static MMMediaManager* _obj = nil;
@implementation MMMediaManager

- (instancetype)init
{
    if(_obj == nil) {
        self = [super init];
        if (self) {
            
        }
    }else {
        @throw [NSException exceptionWithName:@"InitException" reason:@"Please use +sharedManager" userInfo:nil];
    }
    return self;
}

-(MPMediaLibraryAuthorizationStatus)authorizationStatus {
    return [MPMediaLibrary authorizationStatus];
}

+(instancetype)sharedManager {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _obj = [[MMMediaManager alloc] init];
    });
    
    return _obj;
}

-(NSArray *)allMedias {
    MPMediaQuery* query = [[MPMediaQuery alloc] init];
    
    return [query items];
}

-(NSArray*)queryMediasWithTitle:(NSString *)title {
    MPMediaQuery* query = [[MPMediaQuery alloc] init];
    [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:title forProperty:MPMediaItemPropertyTitle]];
    query.groupingType = MPMediaGroupingTitle;
    
    return [query items];
}

-(NSArray*)queryMediasWithArtist:(NSString *)artist {
    MPMediaQuery* query = [[MPMediaQuery alloc] init];
    [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:artist forProperty:MPMediaItemPropertyArtist]];
    query.groupingType = MPMediaGroupingArtist;
    
    return [query items];
}

-(MPMediaItem *)queryMediaItemWithTitle:(NSString *)title artist:(NSString *)artist {
    MPMediaQuery* query = [[MPMediaQuery alloc] init];
    [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:title forProperty:MPMediaItemPropertyTitle]];
    [query addFilterPredicate:[MPMediaPropertyPredicate predicateWithValue:artist forProperty:MPMediaItemPropertyArtist]];
    query.groupingType = MPMediaGroupingTitle;
    
    NSArray* items = [query items];
    if(items.count <= 0)
        return nil;
    return [items firstObject];
}

-(void)requestMediaQueryAuthorizationWhenComplete:(void (^)(MPMediaLibraryAuthorizationStatus))completeHandler {
    return [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completeHandler(status);
        });
    }];
}

@end
