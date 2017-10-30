//
//  MMPopMenu.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/30.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPopMenu.h"

@interface MMPopMenu() <UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, strong) UIWindow* dimWindow;
@property(nonatomic, strong) UIView* menuHostView;
@property(nonatomic, strong) UITableView* menuTableView;

@property(nonatomic, copy) NSArray<NSString*> * items;
@property(nonatomic, assign) NSInteger tracks;

@property(nonatomic, weak) UIView* inView;

@end

@implementation MMPopMenu

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.view.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.5f];
        [self.view addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideMenu)]];
    }
    return self;
}

+(instancetype)menuWithItems:(NSArray<NSString *> *)items tracks:(NSUInteger)tracks {
    MMPopMenu* popMenu = [[MMPopMenu alloc] init];
    
    popMenu.items = items;
    popMenu.tracks = tracks;
    
    return popMenu;
}

-(void)viewDidLoad {
    [super viewDidLoad];
    
    _menuHostView = [[UIView alloc] initWithFrame:CGRectZero];
    _menuHostView.backgroundColor = [UIColor whiteColor];
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
    if(_dimWindow == nil) {
        _dimWindow = [[UIWindow alloc] initWithFrame:SCREEN_BOUNDS];
    }
    
    _inView = inView;
    
    [self makeRotate:orientation];
    
    _dimWindow.rootViewController = self;
    [_dimWindow makeKeyAndVisible];
    _isMenuShown = YES;
    return ;
}

-(void)hideMenu {
    [_dimWindow resignKeyWindow];
    _dimWindow.hidden = YES;
    _isMenuShown = NO;
    return ;
}

-(void)makeRotate:(UIInterfaceOrientation)orientation {
    CGRect frame = [_inView convertRect:_inView.frame toView:self.view];
    
    if(orientation == UIInterfaceOrientationPortrait) {
        _menuHostView.transform = CGAffineTransformIdentity;
    }
    else if(orientation == UIInterfaceOrientationLandscapeLeft) {
        _menuHostView.transform = CGAffineTransformMakeRotation(M_PI_2);
        _menuHostView.frame = CGRectMake(frame.origin.x - 100, frame.origin.y - 100 + frame.size.height / 2, 100, 200);
    }
    else if(orientation == UIInterfaceOrientationLandscapeRight) {
        _menuHostView.transform = CGAffineTransformMakeRotation(-M_PI_2);
        _menuHostView.frame = CGRectMake(frame.origin.x + frame.size.width, frame.origin.y - 100 + frame.size.height / 2, 100, 200);
    }
    return ;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

#pragma mark - UITableViewDelegate & UITableViewDataSource
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 3;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    cell.textLabel.text = [NSString stringWithFormat:@"%ld", (long)indexPath.row];
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10.0f;
}



@end
