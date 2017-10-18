//
//  MMMediaAssetsCollectionViewFlowLayout.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/18.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMMediaAssetsCollectionViewFlowLayout.h"

@interface MMMediaAssetsCollectionViewFlowLayout()

@property(nonatomic, assign) id<MMMediaAssetsCollectionViewFlowLayoutDelegate> delegate;

@end

@implementation MMMediaAssetsCollectionViewFlowLayout

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    return YES;
}

-(void)prepareLayout {
    [super prepareLayout];
    _delegate = (id<MMMediaAssetsCollectionViewFlowLayoutDelegate>)self.collectionView.delegate;
    
    return ;
}

-(NSArray<UICollectionViewLayoutAttributes *> *)layoutAttributesForElementsInRect:(CGRect)rect {
    NSMutableArray* attrsArray = [NSMutableArray array];
    
    NSUInteger sectionCount = [self.collectionView numberOfSections];
    for(int i = 0; i != sectionCount; ++i) {
        NSUInteger itemCount = [self.collectionView numberOfItemsInSection:i];
        for(int j = 0; j != itemCount; ++j) {
            UICollectionViewLayoutAttributes* attrs = [self layoutAttributesForItemAtIndexPath:[NSIndexPath indexPathForItem:j inSection:i]];
            if(CGRectIntersectsRect(attrs.frame, rect) == true)
                [attrsArray addObject:attrs];
        }
    }
    
    return attrsArray;
}

-(UICollectionViewLayoutAttributes *)layoutAttributesForItemAtIndexPath:(NSIndexPath *)indexPath {
    UICollectionViewLayoutAttributes* attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
    
    UICollectionViewCell* cell = [self.collectionView cellForItemAtIndexPath:indexPath];
    
    if(cell != nil) {
        if(indexPath.section == 0) {
            attrs.frame = CGRectMake(indexPath.item * 80, 0, 80, 80);
        }else {
            attrs.frame = CGRectMake(indexPath.item * 100, 100, 100, 100);
        }
    }
    
    return attrs;
}

-(CGSize)collectionViewContentSize {
    return CGSizeMake(500, 500);
}

@end
