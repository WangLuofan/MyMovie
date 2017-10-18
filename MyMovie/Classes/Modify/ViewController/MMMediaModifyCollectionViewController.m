//
//  MMMediaModifyCollectionViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMMediaAssetsCollectionViewFlowLayout.h"
#import "MMMediaModifyCollectionViewController.h"

@interface MMMediaModifyCollectionViewController ()

@end

@implementation MMMediaModifyCollectionViewController

static NSString * const reuseIdentifier = @"Cell";

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:reuseIdentifier];
    
    MMMediaAssetsCollectionViewFlowLayout* flowLayout = (MMMediaAssetsCollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
//    flowLayout.mediaTypes = @[@(0), @(1), @(0), @(0), @(0)];
//    flowLayout.itemSize = CGSizeMake(80, 80);
//    flowLayout.minimumInteritemSpacing = 5;
//    flowLayout.minimumLineSpacing = 5;
//    flowLayout.sectionInset = UIEdgeInsetsMake(5, 5, 5, 5);
    
    return ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 2;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 5;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    
    // Configure the cell
    cell.backgroundColor = [UIColor whiteColor];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

@end
