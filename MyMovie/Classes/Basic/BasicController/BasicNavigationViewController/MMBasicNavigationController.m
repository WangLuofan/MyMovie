//
//  MMBasicNavigationController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMBasicNavigationController.h"

@interface MMBasicNavigationController ()

@end

@implementation MMBasicNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(BOOL)prefersStatusBarHidden {
    return NO;
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    return ;
}

@end
