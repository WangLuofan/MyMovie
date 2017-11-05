//
//  MMPopMenu.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/30.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPopMenu.h"

@interface MMPopMenu() <UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate>

@property(nonatomic, strong) UIWindow* dimWindow;
@property(nonatomic, strong) UITableView* menuTableView;
@property(nonatomic, strong) UIView* menuHostView;

@property(nonatomic, copy) NSArray<NSString*> * items;
@property(nonatomic, assign) NSInteger tracks;

@property(nonatomic, weak) UIView* inView;

@end

@implementation MMPopMenu

- (instancetype)initWithDelegate:(id<MMPopMenuDelegate>)delegate
{
    self = [super init];
    if (self) {
        self.delegate = delegate;
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)];
        tapGesture.delegate = self;
        [self.view addGestureRecognizer:tapGesture];
        
        _tracks = 0;
        _items = nil;
    }
    return self;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    _menuHostView = [[UIView alloc] init];
    [self.view addSubview:_menuHostView];
    
    _menuTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
    _menuTableView.delegate = self;
    _menuTableView.dataSource = self;
    _menuTableView.estimatedSectionFooterHeight = 0.0f;
    _menuTableView.estimatedSectionHeaderHeight = 0.0f;
    [_menuHostView addSubview:_menuTableView];
    [_menuTableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(_menuHostView);
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged) name:UIDeviceOrientationDidChangeNotification object:nil];
    return ;
}

-(void)deviceOrientationChanged {
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    
    NSTimeInterval timeInterval = [[UIApplication sharedApplication] statusBarOrientationAnimationDuration];
    
    [UIView animateWithDuration:timeInterval animations:^{
        if(orientation == UIDeviceOrientationLandscapeLeft)
            [self makeRotate:UIInterfaceOrientationLandscapeLeft];
        else if(orientation == UIDeviceOrientationLandscapeRight)
            [self makeRotate:UIInterfaceOrientationLandscapeRight];
    }];
    
    return ;
}

-(void)showInView:(UIView*)inView orientation:(UIInterfaceOrientation)orientation {
    if([self.delegate respondsToSelector:@selector(numberOfTracks)])
        _tracks = [self.delegate numberOfTracks];
    if([self.delegate respondsToSelector:@selector(itemsForMenu:)])
        _items = [self.delegate itemsForMenu:self];
    [_menuTableView reloadData];
    
    if(_dimWindow == nil) {
        _dimWindow = [[UIWindow alloc] initWithFrame:SCREEN_BOUNDS];
    }
    
    _inView = inView;
    _isMenuShown = YES;
    [self makeRotate:orientation];
    
    _dimWindow.rootViewController = self;
    [_dimWindow makeKeyAndVisible];
    return ;
}

-(void)hideMenu {
    [_dimWindow resignKeyWindow];
    _dimWindow.hidden = YES;
    _isMenuShown = NO;
    return ;
}

-(void)makeRotate:(UIInterfaceOrientation)orientation {
    if(orientation == UIInterfaceOrientationPortrait) {
        self.view.transform = CGAffineTransformIdentity;
    }
    else if(orientation == UIInterfaceOrientationLandscapeLeft) {
        self.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    }
    else if(orientation == UIInterfaceOrientationLandscapeRight) {
        self.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    
    self.view.frame = SCREEN_BOUNDS;
    if([[UIDevice currentDevice].systemVersion doubleValue] < 11.0f)
        _menuHostView.frame = CGRectMake(_inView.frame.origin.x - 100 + _inView.frame.size.width / 2, _inView.frame.origin.y + _inView.frame.size.height, 200, 250);
    else {
        CGRect frame = [_inView convertRect:_inView.frame toView:self.view];
        _menuHostView.frame = CGRectMake(frame.origin.x + frame.size.width / 2 - 100, frame.origin.y + frame.size.height, 200, 250);
    }
    return ;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_tracks == 0 && _items.count == 0)
        return 0;
    if((_tracks != 0 && _items.count == 0) || (_tracks == 0 && _items.count != 0))
        return 1;
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(_tracks != 0 && section == 0)
        return _tracks;
    return _items.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    if(indexPath.section == 0)
        cell.textLabel.text = [NSString stringWithFormat:@"Track %ld", (long)indexPath.row];
    else
        cell.textLabel.text = [_items objectAtIndex:(NSUInteger)indexPath.row];
    
    cell.textLabel.textAlignment = NSTextAlignmentCenter;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 30.0f;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if(_tracks != 0 && section == 0)
        return @"编辑音轨";
    return @"菜单选项";
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    BOOL bTrack = (_tracks != 0 && indexPath.section == 0);
    if([self.delegate respondsToSelector:@selector(popMenu:itemSelectedAtIndexPath:bTrack:)])
        [self.delegate popMenu:self itemSelectedAtIndexPath:indexPath bTrack:bTrack];
    
    [self hideMenu];
    return ;
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if(CGRectContainsPoint(_menuHostView.bounds, [gestureRecognizer locationInView:_menuHostView]))
        return NO;
    return YES;
}

@end
