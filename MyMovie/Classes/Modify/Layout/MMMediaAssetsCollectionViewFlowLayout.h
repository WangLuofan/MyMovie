//
//  MMMediaAssetsCollectionViewFlowLayout.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/18.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MMMediaAssetsCollectionViewFlowLayout;
@protocol MMMediaAssetsCollectionViewFlowLayoutDelegate <UICollectionViewDelegate>

@required
-(NSUInteger)collectionView:(UICollectionView*)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout*)layout assetsTypeForItemAtIndexPath:(NSIndexPath*)indexPath;

@optional
-(CGSize)collectionView:(UICollectionView*)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout*)layou sizeForItemAtIndexPath:(NSIndexPath*)indexPath;
-(void)collectionView:(UICollectionView *)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout *)layout didDeleteItemAtIndexPath:(NSIndexPath *)indexPath;
-(void)collectionView:(UICollectionView*)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout*)layout didAdjustItemAtIndexPath:(NSIndexPath*)indexPath toWidth:(CGFloat)width;
-(BOOL)collectionView:(UICollectionView*)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout*)layout canAdjustItemAtIndexPath:(NSIndexPath*)indexPath;
-(BOOL)collectionView:(UICollectionView*)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout*)layout canMoveItemAtIndexPath:(NSIndexPath*)indexPath;
-(void)collectionView:(UICollectionView*)collectionView layout:(MMMediaAssetsCollectionViewFlowLayout*)layout didMoveItemAtIndexPath:(NSIndexPath*)srcIndexPath toIndexPath:(NSIndexPath*)dstIndexPath;

@end

@interface MMMediaAssetsCollectionViewFlowLayout : UICollectionViewLayout

@property(nonatomic) CGSize itemSize;
@property(nonatomic) CGFloat minimumSpacing;
@property(nonatomic) NSTimeInterval currentTime;

@end
