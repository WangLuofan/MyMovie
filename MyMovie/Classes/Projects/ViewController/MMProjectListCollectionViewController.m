//
//  MMProjectListCollectionViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPhotoManager.h"
#import "MMProjectListCollectionViewCell.h"
#import "MMProjectEdittingViewController.h"
#import "MMProjectListCollectionViewController.h"

#define kProjectListCollectionViewCellIdentifier @"ProjectListCollectionViewCellIdentifier"
#define kDefaultItemCountPerRow 2
#define kMinimumSpacingInterItem 5

@interface MMProjectListCollectionViewController ()

@end

@implementation MMProjectListCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:nibNamed(@"MMProjectListCollectionViewCell") forCellWithReuseIdentifier:kProjectListCollectionViewCellIdentifier];
    
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    CGFloat itemWidth = (SCREEN_WIDTH - (kDefaultItemCountPerRow + 1) * kMinimumSpacingInterItem) / kDefaultItemCountPerRow;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.minimumLineSpacing = kMinimumSpacingInterItem;
    flowLayout.minimumInteritemSpacing = kMinimumSpacingInterItem;
    flowLayout.sectionInset = UIEdgeInsetsMake(kMinimumSpacingInterItem, kMinimumSpacingInterItem, 0, kMinimumSpacingInterItem);
    
    return ;
}

-(void)editMediaProjectWithTitle:(NSString*)projectTitle {
    MMProjectEdittingViewController* edittingController = (MMProjectEdittingViewController*)[storyBoardNamed(@"Main") instantiateViewControllerWithIdentifier:@"MMProjectEdittingViewController"];
    edittingController.title = projectTitle;
    [self.navigationController pushViewController:edittingController animated:YES];

    return ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMProjectListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kProjectListCollectionViewCellIdentifier forIndexPath:indexPath];
    
    cell.projectTitleLabel.text = @"创建项目";
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"新建项目" message:nil preferredStyle:UIAlertControllerStyleAlert];
    [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入项目名称";
    }];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if([MMPhotoManager sharedManager].authorizationStatus != MMAuthorizationStatusAuthorized) {
                [[MMPhotoManager sharedManager] requestAuthorization:^(MMAuthorizationStatus status) {
                    [self editMediaProjectWithTitle:[alertController.textFields objectAtIndex:0].text];
                }];
            }else {
                [self editMediaProjectWithTitle:[alertController.textFields objectAtIndex:0].text];
            }
        });
    }]];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    return ;
}

@end
