//
//  MMTransitionModifyView.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/21.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMMediaItemModel;
@class MMTransitionModifyView;

@protocol MMTransitionModifyViewDelegate <NSObject>

@optional
-(void)transitionViewDidHide:(MMTransitionModifyView*)transitionView;
-(void)transitionView:(MMTransitionModifyView*)transtionView willSaveDataWithModel:(MMMediaItemModel*)model;

@end

@interface MMTransitionModifyView : UIView

@property(nonatomic, assign) id<MMTransitionModifyViewDelegate> delegate;

-(void)showInView:(UIView*)inView withModel:(MMMediaItemModel*)model;
-(void)hide;

@end
