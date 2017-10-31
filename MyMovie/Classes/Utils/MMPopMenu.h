//
//  MMPopMenu.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/30.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMPopMenu;
@protocol MMPopMenuDelegate <NSObject>

@optional
-(void)popMenu:(MMPopMenu*)popMenu itemSelectedAtIndexPath:(NSIndexPath*)indexPath bTrack:(BOOL)bTrack;
-(NSInteger)numberOfTracks;
-(NSArray*)itemsForMenu:(MMPopMenu*)popMenu;

@end

@interface MMPopMenu : UIViewController

@property(nonatomic, assign) id<MMPopMenuDelegate> delegate;
@property(nonatomic, assign) BOOL isMenuShown;

-(instancetype)initWithDelegate:(id<MMPopMenuDelegate>)delegate;
-(void)showInView:(UIView*)inView orientation:(UIInterfaceOrientation)orientation;
-(void)hideMenu;

@end
