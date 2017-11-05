//
//  MMAudioMixModifyTableViewCell.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/31.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMStepView;
@class MMAudioMixModel;
@interface MMAudioMixModifyTableViewCell : UITableViewCell

@property(nonatomic, strong) MMAudioMixModel* audioMixModel;
@property(nonatomic, assign) NSTimeInterval duration;
@property(nonatomic, assign) NSTimeInterval previousTimeInterval;

@end
