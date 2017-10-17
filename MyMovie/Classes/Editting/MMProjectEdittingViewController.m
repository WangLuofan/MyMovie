//
//  MMProjectEdittingViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMProjectEdittingViewController.h"

@interface MMProjectEdittingViewController ()

@end

@implementation MMProjectEdittingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeRotate:UIInterfaceOrientationLandscapeLeft];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    return ;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    return ;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self makeRotate:UIInterfaceOrientationPortrait];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    return ;
}

-(void)makeRotate:(UIInterfaceOrientation)orientation {
    if(orientation == UIInterfaceOrientationPortrait) {
        self.navigationController.view.transform = CGAffineTransformIdentity;
    }else if(orientation == UIInterfaceOrientationLandscapeLeft) {
        self.navigationController.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    }else if(orientation == UIInterfaceOrientationLandscapeRight) {
        self.navigationController.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    
    self.navigationController.view.frame = SCREEN_BOUNDS;
    return ;
}

-(void)deviceOrientationChanged:(NSNotification*)notification {
    NSTimeInterval animateDuration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    UIDeviceOrientation deviceOri = ((UIDevice*)notification.object).orientation;
    
    if(UIDeviceOrientationIsLandscape(deviceOri) == NO)
        return ;
    
    [UIView animateWithDuration:animateDuration animations:^{
        if(deviceOri == UIDeviceOrientationLandscapeLeft)
            [self makeRotate:UIInterfaceOrientationLandscapeLeft];
        else
            [self makeRotate:UIInterfaceOrientationLandscapeRight];
    }];
    
    return ;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
