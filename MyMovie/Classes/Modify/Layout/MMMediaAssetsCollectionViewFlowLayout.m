//
//  MMMediaAssetsCollectionViewFlowLayout.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/18.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPhotoManager.h"
#import "MMMediaModifyItemCollectionViewCell.h"
#import "MMMediaAssetsCollectionViewFlowLayout.h"

#define NSIndexPathSame(indexPath1, indexPath2) (indexPath1.section == indexPath2.section && indexPath1.item == indexPath2.item)
#define NSStringFromIndexPath(indexPath) [NSString stringWithFormat:@"{section = %ld, item = %ld}", indexPath.section, indexPath.item]

@interface MMLayoutAttributeFrameHeight : NSObject

@property(nonatomic) CGFloat curMaxHeight;
@property(nonatomic) CGFloat preMaxHeight;

@end

@implementation MMLayoutAttributeFrameHeight
@end

typedef NS_OPTIONS(NSUInteger, MMDragMode) {
    MMDragModeTrim,
    MMDragModeDrag,
};

@interface MMMediaAssetsCollectionViewFlowLayout() <UIGestureRecognizerDelegate>

@property(nonatomic, assign) id<MMMediaAssetsCollectionViewFlowLayoutDelegate> delegate;
@property(nonatomic, strong) NSMutableDictionary* calculatedLayoutAttributes;
@property(nonatomic, strong) NSMutableArray* calculatedLayoutFrames;            //cell frame 缓存
@property(nonatomic, strong) NSMutableArray* calculatedMaxSectionHeight;

@property(nonatomic, strong) NSIndexPath* gestrureIndexPath;

@property(nonatomic, assign) MMDragMode dragMode;
@property(nonatomic, strong) UIImageView* draggableImageView;

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
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureAction:)];
    panGesture.delegate = self;
    
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGestureAction:)];
    longPressGesture.delegate = self;
    longPressGesture.minimumPressDuration = 0.5f;
    
    [self.collectionView addGestureRecognizer:tapGesture];
    [self.collectionView addGestureRecognizer:panGesture];
    [self.collectionView addGestureRecognizer:longPressGesture];
    
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
    else if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]){
        CGPoint location = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:location];
        
        //点按处无Cell
        if(indexPath == nil)
            return NO;
        
        //特效宽度无法调整
        MMAssetMediaType mediaType = [self.delegate collectionView:self.collectionView layout:self assetsTypeForItemAtIndexPath:indexPath];
        if(mediaType == MMAssetMediaTypeTransition)
            return NO;
        
        if(_dragMode == MMDragModeTrim) {
            //不能调整
            if([self.delegate respondsToSelector:@selector(collectionView:layout:canAdjustItemAtIndexPath:)])
                if([self.delegate collectionView:self.collectionView layout:self canAdjustItemAtIndexPath:indexPath] == NO)
                    return NO;
            
            UICollectionViewLayoutAttributes* attr = [self layoutAttributesForItemAtIndexPath:indexPath];
            if(CGRectContainsPoint(CGRectMake(attr.frame.origin.x + attr.frame.size.width - 50, attr.frame.origin.y, 50, attr.frame.size.height), location) == true)
                return YES;
        }else {
            if([self.delegate respondsToSelector:@selector(collectionView:layout:canMoveItemAtIndexPath:)])
                if([self.delegate collectionView:self.collectionView layout:self canMoveItemAtIndexPath:indexPath] == NO)
                    return NO;
        }
    }else {
        CGPoint location = [gestureRecognizer locationInView:self.collectionView];
        NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:location];
        
        if(indexPath == nil)
            return NO;
        
        if([self.delegate respondsToSelector:@selector(collectionView:layout:canMoveItemAtIndexPath:)])
            if([self.delegate collectionView:self.collectionView layout:self canMoveItemAtIndexPath:indexPath] == NO)
                return NO;
        
        MMAssetMediaType mediaType = [self.delegate collectionView:self.collectionView layout:self assetsTypeForItemAtIndexPath:indexPath];
        if(mediaType == MMAssetMediaTypeTransition)
            return NO;
    }
    
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)recognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherRecognizer {
    if([recognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
        return NO;
    return YES;
}

#pragma mark - 手势处理
-(void)handlePanGestureAction:(UIGestureRecognizer*)recognizer {
    CGPoint location = [recognizer locationInView:self.collectionView];
    CGPoint offset = [((UIPanGestureRecognizer*)recognizer) translationInView:self.collectionView];
    
    NSIndexPath* newIndexPath = [self.collectionView indexPathForItemAtPoint:location];
    
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [recognizer locationInView:self.collectionView];
        _gestrureIndexPath = [self.collectionView indexPathForItemAtPoint:point];
    }else if(recognizer.state == UIGestureRecognizerStateChanged) {
        if(_dragMode == MMDragModeDrag) {
            
            UICollectionViewCell* curCell = [self.collectionView cellForItemAtIndexPath:_gestrureIndexPath];
            if(curCell != nil)
                curCell.hidden = YES;
            
            _draggableImageView.center = CGPointMake(_draggableImageView.center.x + offset.x, _draggableImageView.center.y + offset.y);
            
            if(newIndexPath != nil &&[self.delegate collectionView:self.collectionView layout:self assetsTypeForItemAtIndexPath:newIndexPath] != MMAssetMediaTypeTransition && newIndexPath != _gestrureIndexPath && newIndexPath.section == _gestrureIndexPath.section) {
                
                NSMutableArray* frameArray = [_calculatedLayoutFrames objectAtIndex:(NSUInteger)newIndexPath.section];
                [frameArray removeAllObjects];
                
                NSArray* allKeys = _calculatedLayoutAttributes.allKeys;
                for(NSIndexPath* indexPath in allKeys) {
                    if(indexPath.section == _gestrureIndexPath.section)
                        [_calculatedLayoutAttributes removeObjectForKey:indexPath];
                }
            }
            
        }else if(_dragMode == MMDragModeTrim) {
            
            UICollectionViewLayoutAttributes* attrs = [_calculatedLayoutAttributes objectForKey:_gestrureIndexPath];
            
            if(attrs.frame.size.width + offset.x < 5.0f)
                return ;
            
            attrs.frame = CGRectMake(attrs.frame.origin.x, attrs.frame.origin.y, attrs.frame.size.width + offset.x, attrs.frame.size.height);
            
            NSMutableArray* frameArr = [_calculatedLayoutFrames objectAtIndex:(NSUInteger)_gestrureIndexPath.section];
            [frameArr replaceObjectAtIndex:(NSUInteger)_gestrureIndexPath.item withObject:[NSValue valueWithCGRect:attrs.frame]];
            
            for (NSIndexPath* indexPath in _calculatedLayoutAttributes.allKeys) {
                if(indexPath.section == _gestrureIndexPath.section && indexPath.item > _gestrureIndexPath.item) {
                    UICollectionViewLayoutAttributes* otAttrs = [_calculatedLayoutAttributes objectForKey:indexPath];
                    otAttrs.frame = CGRectMake(otAttrs.frame.origin.x + offset.x, otAttrs.frame.origin.y, otAttrs.frame.size.width, otAttrs.frame.size.height);
                    [frameArr replaceObjectAtIndex:(NSUInteger)indexPath.item withObject:[NSValue valueWithCGRect:otAttrs.frame]];
                }
            }
            
            [self invalidateLayout];
        }
        [((UIPanGestureRecognizer*)recognizer) setTranslation:CGPointZero inView:self.collectionView];
    }else if(recognizer.state == UIGestureRecognizerStateEnded) {
        if(_dragMode == MMDragModeTrim) {
            NSMutableArray* frameArr = [_calculatedLayoutFrames objectAtIndex:(NSUInteger)_gestrureIndexPath.section];
            
            if([self.delegate respondsToSelector:@selector(collectionView:layout:didAdjustItemAtIndexPath:toWidth:)])
                [self.delegate collectionView:self.collectionView layout:self didAdjustItemAtIndexPath:_gestrureIndexPath toWidth:[[frameArr objectAtIndex:(NSUInteger)_gestrureIndexPath.item] CGRectValue].size.width];
        }else {
            UICollectionViewCell* curCell = [self.collectionView cellForItemAtIndexPath:_gestrureIndexPath];
            if(curCell != nil)
                curCell.hidden = NO;
            
            [_draggableImageView removeFromSuperview];
            _draggableImageView = nil;
            
            _dragMode = MMDragModeTrim;
            
            if([self.delegate respondsToSelector:@selector(collectionView:layout:didMoveItemAtIndexPath:toIndexPath:)]) {
                [self.delegate collectionView:self.collectionView layout:self didMoveItemAtIndexPath:_gestrureIndexPath toIndexPath:newIndexPath];
            }
        }
        
        [self invalidateLayout];
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

-(void)handleLongPressGestureAction:(UIGestureRecognizer*)recognizer {
    CGPoint touchPoint = [recognizer locationInView:self.collectionView];
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:touchPoint];
    
    if(indexPath == nil) return ;
    
    MMAssetMediaType mediaType = [self.delegate collectionView:self.collectionView layout:self assetsTypeForItemAtIndexPath:indexPath];
    
    if(mediaType == MMAssetMediaTypeTransition)
        return ;
    
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint point = [recognizer locationInView:self.collectionView];
        _gestrureIndexPath = [self.collectionView indexPathForItemAtPoint:point];
        
        MMMediaModifyItemCollectionViewCell* cell = (MMMediaModifyItemCollectionViewCell*)[self.collectionView cellForItemAtIndexPath:_gestrureIndexPath];
        
        if(cell == nil) return ;
        self.draggableImageView = [[UIImageView alloc] initWithImage:[cell toImage]];
        
        [self.collectionView addSubview:self.draggableImageView];
        self.draggableImageView.frame = cell.frame;
        
        _dragMode = MMDragModeDrag;
    } else if(recognizer.state == UIGestureRecognizerStateEnded) {
        if(_draggableImageView != nil) {
            [_draggableImageView removeFromSuperview];
            _draggableImageView = nil;
        }
        
        UICollectionViewCell* curCell = [self.collectionView cellForItemAtIndexPath:_gestrureIndexPath];
        if(curCell != nil)
            curCell.hidden = NO;
        
        _dragMode = MMDragModeTrim;
    }
    return ;
}

@end
