//
//  MMMediaAssetsTableViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//
#import "MMTimerManager.h"
#import "MMMediaAssetsTableViewController.h"

@interface MMMediaAssetsTableViewController ()

@end

@implementation MMMediaAssetsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(gotoBack)];
    
    return ;
}

-(void)gotoBack {
    [[MMTimerManager sharedManager] removeAllTimers];
    
    [self.parentViewController.navigationController popViewControllerAnimated:YES];
    return ;
}

@end
