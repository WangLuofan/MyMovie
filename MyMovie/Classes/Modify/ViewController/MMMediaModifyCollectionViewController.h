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
@interface MMMediaModifyCollectionViewController : MMBasicCollectionViewController

-(void)prepareForPlay;
-(void)insertItemWithMediaItemModel:(MMMediaItemModel*)model;

@end
