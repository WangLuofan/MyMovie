//
//  MMMediaAssetsCollectionViewFlowLayout.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/18.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPhotoManager.h"
#import "MMMediaAssetsCollectionViewFlowLayout.h"

#define NSIndexPathSame(indexPath1, indexPath2) (indexPath1.section == indexPath2.section && indexPath1.item == indexPath2.item)

@interface MMLayoutAttributeFrameHeight : NSObject

@property(nonatomic) CGFloat curMaxHeight;
@property(nonatomic) CGFloat preMaxHeight;

@end

@implementation MMLayoutAttributeFrameHeight
@end

@interface MMMediaAssetsCollectionViewFlowLayout() <UIGestureRecognizerDelegate>

@property(nonatomic, assign) id<MMMediaAssetsCollectionViewFlowLayoutDelegate> delegate;
@property(nonatomic, strong) NSMutableDictionary* calculatedLayoutAttributes;
@property(nonatomic, strong) NSMutableArray* calculatedLayoutFrames;            //cell frame 缓存
@property(nonatomic, strong) NSMutableArray* calculatedMaxSectionHeight;

@end

@implementation MMMediaAssetsCollectionViewFlowLayout

-(void)awakeFromNib {
    [super awakeFromNib];
    
    _delegate = (id<MMMediaAssetsCollectionViewFlowLayoutDelegate>)self.collectionView.delegate;
    
    _calculatedLayoutAttributes = [NSMutableDictionary dictionary];
    _calculatedLayoutFrames = [NSMutableArray array];
    _calculatedMaxSectionHeight = [NSMutableArray array];
    
    _itemSize = CGSizeMake(80.0f, 80.0f);
    _minimumSpacing = 0.0f;
    
    UITapGestureRecognizer* tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureAction:)];
    tapGesture.numberOfTapsRequired = 2;
    tapGesture.delegate = self;
    [self.collectionView addGestureRecognizer:tapGesture];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureAction:)];
    [self.collectionView addGestureRecognizer:panGesture];
    
    return ;
}

-(void)handlePanGestureAction:(UIGestureRecognizer*)recognizer {
    
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint touchPoint = [recognizer locationInView:self.collectionView];
        NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    }else if(recognizer.state == UIGestureRecognizerStateChanged) {
        
    }else if(recognizer.state == UIGestureRecognizerStateEnded) {
        
    }
    return ;
}

-(void)handleTapGestureAction:(UIGestureRecognizer*)recognizer {
    
    CGPoint touchPoint = [recognizer locationInView:self.collectionView];
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    
    if(indexPath == nil) return ;
    
    MMAssetMediaType mediaType = [self.delegate collectionView:self.collectionView layout:self assetsTypeForItemAtIndexPath:indexPath];
    
    if(mediaType == MMAssetMediaTypeTransition)
        return ;
    
    NSMutableArray* framesArr = (NSMutableArray*)[_calculatedLayoutFrames objectAtIndex:(NSUInteger)indexPath.section];
    if(framesArr.count == 1 && indexPath.section == 0) {
        [_calculatedLayoutAttributes removeAllObjects];
        [_calculatedLayoutFrames removeAllObjects];
    }
    else {
        NSArray* allKeys = _calculatedLayoutAttributes.allKeys;
        for (NSIndexPath* curIndexPath in allKeys) {
            if(curIndexPath.section == indexPath.section) {
                [_calculatedLayoutAttributes removeObjectForKey:curIndexPath];
            }
        }
        [framesArr removeAllObjects];
    }
    
    if([self.delegate respondsToSelector:@selector(collectionView:layout:didDeleteItemAtIndexPath:)])
        [self.delegate collectionView:self.collectionView layout:self didDeleteItemAtIndexPath:indexPath];
    
    return ;
}

-(BOOL)shouldInvalidateLayoutForBoundsChange:(CGRect)newBounds {
    CGRect visibleRect = CGRectMake(self.collectionView.contentOffset.x, 0, self.collectionView.bounds.size.width, self.collectionView.bounds.size.height);
    
    return (CGRectIntersectsRect(newBounds, visibleRect)) == true;
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
    UICollectionViewLayoutAttributes* attrs = nil;
    if(_calculatedLayoutAttributes[indexPath] == nil) {
        attrs = [UICollectionViewLayoutAttributes layoutAttributesForCellWithIndexPath:indexPath];
        
        MMAssetMediaType mediaType = [_delegate collectionView:self.collectionView layout:self assetsTypeForItemAtIndexPath:indexPath];
        
        if(mediaType == MMAssetMediaTypeUnknown)
            return attrs;
        
        CGSize itemSize = _itemSize;
        if([_delegate respondsToSelector:@selector(collectionView:layout:sizeForItemAtIndexPath:)])
            itemSize = [_delegate collectionView:self.collectionView layout:self sizeForItemAtIndexPath:indexPath];
        
        if(_calculatedLayoutFrames.count <= indexPath.section)
            [_calculatedLayoutFrames addObject:[NSMutableArray array]];
        
        NSMutableArray* frameArray = [_calculatedLayoutFrames objectAtIndex:(NSUInteger)indexPath.section];
//        if(frameArray.count > indexPath.item)
//            return [frameArray objectAtIndex:(NSUInteger)indexPath.item];
        
        CGFloat preWidth = 0.0f;
        for(int i = 0; i != indexPath.item; ++i)
            preWidth += [[frameArray objectAtIndex:i] CGRectValue].size.width;
        
        CGFloat maxHeight = 0.0f;
        if(indexPath.section != 0)
            maxHeight = (((MMLayoutAttributeFrameHeight*)[_calculatedMaxSectionHeight objectAtIndex:(NSUInteger)(indexPath.section - 1)])).preMaxHeight + (((MMLayoutAttributeFrameHeight*)[_calculatedMaxSectionHeight objectAtIndex:(NSUInteger)(indexPath.section - 1)])).curMaxHeight;
        
        if(mediaType != MMAssetMediaTypeTransition)
            attrs.frame = CGRectMake((indexPath.item + 1) * _minimumSpacing + preWidth, (indexPath.section + 1) * _minimumSpacing + maxHeight, itemSize.width, itemSize.height);
        else {
            
            attrs.frame = CGRectMake((indexPath.item + 1) * _minimumSpacing + preWidth, 0, itemSize.width, itemSize.height);
            attrs.center = CGPointMake(attrs.center.x, ((indexPath.section + 1) * _minimumSpacing + maxHeight + [[frameArray objectAtIndex:(NSUInteger)(indexPath.item - 1)] CGRectValue].size.height) / 2);
        }
        
        if(frameArray.count <= indexPath.item)
            [frameArray addObject:[NSValue valueWithCGRect:attrs.frame]];
        
        if(_calculatedMaxSectionHeight.count <= indexPath.section) {
            MMLayoutAttributeFrameHeight* frameHeight = [[MMLayoutAttributeFrameHeight alloc] init];
            frameHeight.curMaxHeight = itemSize.height;
            if(indexPath.section != 0) {
                MMLayoutAttributeFrameHeight* preFrameHeight = [_calculatedMaxSectionHeight objectAtIndex:(NSUInteger)indexPath.section - 1];
                frameHeight.preMaxHeight = preFrameHeight.preMaxHeight + preFrameHeight.curMaxHeight;
            }
            
            [_calculatedMaxSectionHeight addObject:frameHeight];
        }
        
        [_calculatedLayoutAttributes setObject:attrs forKey:[indexPath copy]];
    }else {
        attrs = [_calculatedLayoutAttributes objectForKey:indexPath];
    }
    
    return attrs;
}

-(CGSize)collectionViewContentSize {
    CGSize contentSize = CGSizeZero;
    
    if(_calculatedMaxSectionHeight.count != 0) {
        MMLayoutAttributeFrameHeight* frameHeight = (MMLayoutAttributeFrameHeight*)[_calculatedMaxSectionHeight objectAtIndex:(_calculatedMaxSectionHeight.count - 1)];
        contentSize.height = frameHeight.curMaxHeight + frameHeight.preMaxHeight + _minimumSpacing * _calculatedMaxSectionHeight.count;
    }
    
    if(_calculatedLayoutFrames.count != 0) {
        for(NSArray* secFrames in _calculatedLayoutFrames) {
            CGFloat contentWidth = 0.0f;
            for (NSValue* frame in secFrames)
                contentWidth += [frame CGRectValue].size.width;
            contentWidth += ((secFrames.count + 1) * _minimumSpacing);
            
            if(contentWidth >= contentSize.width)
                contentSize.width = contentWidth;
        }
    }
    
    return contentSize;
}

#pragma mark - UIGestureRecognizerDelegate

@end
