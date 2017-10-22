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

@property(nonatomic, strong) NSIndexPath* panIndexPath;
@property(nonatomic, assign) CGFloat xOffset;

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
    panGesture.delegate = self;
    [self.collectionView addGestureRecognizer:panGesture];
    
    return ;
}

-(void)handlePanGestureAction:(UIGestureRecognizer*)recognizer {
    
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [recognizer locationInView:self.collectionView];
        _panIndexPath = [self.collectionView indexPathForItemAtPoint:point];
        
        _xOffset = 0.0f;
    }else if(recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint offset = [((UIPanGestureRecognizer*)recognizer) translationInView:self.collectionView];
        
        UICollectionViewLayoutAttributes* attrs = [_calculatedLayoutAttributes objectForKey:_panIndexPath];
        attrs.frame = CGRectMake(attrs.frame.origin.x, attrs.frame.origin.y, attrs.frame.size.width + offset.x - _xOffset, attrs.frame.size.height);
        
        NSMutableArray* frameArr = [_calculatedLayoutFrames objectAtIndex:(NSUInteger)_panIndexPath.section];
        [frameArr replaceObjectAtIndex:(NSUInteger)_panIndexPath.item withObject:[NSValue valueWithCGRect:attrs.frame]];
        
        for (NSIndexPath* indexPath in _calculatedLayoutAttributes.allKeys) {
            if(indexPath.section == _panIndexPath.section && indexPath.item > _panIndexPath.item) {
                UICollectionViewLayoutAttributes* otAttrs = [_calculatedLayoutAttributes objectForKey:indexPath];
                otAttrs.frame = CGRectMake(otAttrs.frame.origin.x + offset.x - _xOffset, otAttrs.frame.origin.y, otAttrs.frame.size.width, otAttrs.frame.size.height);
                [frameArr replaceObjectAtIndex:(NSUInteger)indexPath.item withObject:[NSValue valueWithCGRect:otAttrs.frame]];
            }
        }
        
        _xOffset = offset.x;
        [self invalidateLayout];
    }else if(recognizer.state == UIGestureRecognizerStateEnded) {
        if([self.delegate respondsToSelector:@selector(collectionView:layout:didAdjustItemAtIndexPath:xOffset:)])
            [self.delegate collectionView:self.collectionView layout:self didAdjustItemAtIndexPath:_panIndexPath xOffset:[((UIPanGestureRecognizer*)recognizer) translationInView:self.collectionView].x];
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
        
        [_calculatedLayoutAttributes setObject:attrs forKey:indexPath];
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
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if([gestureRecognizer isKindOfClass:[UITapGestureRecognizer class]])
        return YES;
    else {
        CGPoint location = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:location];
        
        //点按处无Cell
        if(indexPath == nil)
            return NO;
        
        //不能调整
        if([self.delegate respondsToSelector:@selector(collectionView:layout:canAdjustItemAtIndexPath:)])
            if([self.delegate collectionView:self.collectionView layout:self canAdjustItemAtIndexPath:indexPath] == NO)
                return NO;
        
        //特效宽度无法调整
        MMAssetMediaType mediaType = [self.delegate collectionView:self.collectionView layout:self assetsTypeForItemAtIndexPath:indexPath];
        if(mediaType == MMAssetMediaTypeTransition)
            return NO;
        
        UICollectionViewLayoutAttributes* attr = [self layoutAttributesForItemAtIndexPath:indexPath];
        if(CGRectContainsPoint(CGRectMake(attr.frame.origin.x + attr.frame.size.width - 50, attr.frame.origin.y, 50, attr.frame.size.height), location) == true)
            return YES;
    }
    return NO;
}

@end
