//
//  MMMediaAssetsCollectionViewFlowLayout.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/18.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol MMMediaAssetsCollectionViewFlowLayoutDelegate <UICollectionViewDelegate>

@end

@interface MMMediaAssetsCollectionViewFlowLayout : UICollectionViewLayout

@property(nonatomic) CGFloat itemHeight;
@property(nonatomic) CGFloat minimum;

@end
