//
//  MMMediaModifyCollectionViewController.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMBasicCollectionViewController.h"

@class MMMediaItemModel;
@class AVPlayerItem;
@class MMTransitionModifyView;
@class MMMediaPreviewViewController;

@interface MMMediaModifyCollectionViewController : MMBasicCollectionViewController

@property(nonatomic, strong) NSMutableArray* audioDataSource;
@property(nonatomic, strong) NSMutableArray* assetsDataSource;

@property(nonatomic, strong) MMTransitionModifyView* transitionModifyView;
@property(nonatomic, weak) MMMediaPreviewViewController* previewViewController;

-(void)load;
-(void)save;
-(void)prepareForPlay;
-(void)updateProgress:(NSTimeInterval)curTime;
-(void)reloadAudioTrackAtIndex:(NSInteger)index;
-(void)insertItemWithMediaItemModel:(MMMediaItemModel*)model;

@end
