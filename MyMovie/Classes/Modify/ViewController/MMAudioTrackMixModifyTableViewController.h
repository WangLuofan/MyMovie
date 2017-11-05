//
//  MMAudioTrackMixModifyTableViewController.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/31.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMBasicTableViewController.h"

@class MMMediaAudioModel;
@class MMMediaModifyCollectionViewController;
@interface MMAudioTrackMixModifyTableViewController : MMBasicTableViewController

-(instancetype)initWithModifyViewController:(MMMediaModifyCollectionViewController*)viewController;
@property(nonatomic, strong) MMMediaAudioModel* audioModel;

@end
