//
//  MMMediaAssetsCollectionViewFlowLayout.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/18.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPhotoManager.h"
#import "MMAssetPlayerControl.h"
#import "MMMediaModifyItemCollectionViewCell.h"
#import "MMMediaAssetsCollectionViewFlowLayout.h"
#import "UIView+MMRender.h"

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

@property(nonatomic, strong) UIView* progressIndicatorLine;
@property(nonatomic, assign) CGFloat progressUnit;

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
    
    [self.collectionView addSubview:self.progressIndicatorLine];
    
    [MMNotificationCenter addObserver:self selector:@selector(videoPlayStatusChanged:) name:kMovieVideoPlayStateChangedNotification object:nil];
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

-(UIView*)progressIndicatorLine {
    if(_progressIndicatorLine == nil) {
        _progressIndicatorLine = [[UIView alloc] initWithFrame:CGRectMake(5.0f, 0.0f, 2.0f, self.collectionView.bounds.size.height)];
        _progressIndicatorLine.backgroundColor = [UIColor whiteColor];
        _progressIndicatorLine.hidden = YES;
    }
    
    return _progressIndicatorLine;
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
            
            UICollectionViewLayoutAttributes* attrs = [_calculatedLayoutAttributes objectForKey:indexPath];
            
            CGFloat xOffset = attrs.frame.origin.x + attrs.frame.size.width - 50.0f;
            if(xOffset < attrs.frame.origin.x) xOffset = attrs.frame.origin.x;
            
            CGFloat xWidth = attrs.frame.size.width - xOffset > 50.0f ? 50.0f : attrs.size.width;
            
            if(CGRectContainsPoint(CGRectMake(xOffset, attrs.frame.origin.y, xWidth, attrs.frame.size.height), location) == false)
                return NO;
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
            
            if(attrs.frame.size.width + offset.x < 25.0f)
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
            
            if(_draggableImageView != nil) {
                [_draggableImageView removeFromSuperview];
                _draggableImageView = nil;
            }
            
            _dragMode = MMDragModeTrim;
            
            if([self.delegate respondsToSelector:@selector(collectionView:layout:didMoveItemAtIndexPath:toIndexPath:)] && _gestrureIndexPath != nil && newIndexPath != nil) {
                [self.delegate collectionView:self.collectionView layout:self didMoveItemAtIndexPath:_gestrureIndexPath toIndexPath:newIndexPath];
            }
        }
        
        self.collectionView.scrollEnabled = YES;
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
        
        self.collectionView.scrollEnabled = NO;
    }
    return ;
}

#pragma mark -
-(CGFloat)progressUnit {
    if(_progressUnit == 0.0f) {
        
        CGFloat totalWidth = 0.0f;
        
        //section 0
        if(_calculatedLayoutFrames.count > 0) {
            NSArray* secFrames = [_calculatedLayoutFrames objectAtIndex:0];
            CGFloat contentWidth = 0.0f;
            for(int i = 0; i < secFrames.count; i += 2)
                contentWidth += [[secFrames objectAtIndex:i] CGRectValue].size.width;
            
            if(totalWidth <= contentWidth)
                totalWidth = contentWidth;
        }
        
        //section 1
        if(_calculatedLayoutFrames.count > 1) {
            NSArray* secFrames = [_calculatedLayoutFrames objectAtIndex:1];
            CGFloat contentWidth = 0.0f;
            for(NSValue* frameVal in secFrames)
                contentWidth += [frameVal CGRectValue].size.width;
            
            if(totalWidth <= contentWidth)
                totalWidth = contentWidth;
        }
        _progressUnit = [self collectionViewContentSize].width * 5.0f / totalWidth;
    }
    
    return _progressUnit;
}

-(void)setCurrentTime:(NSTimeInterval)currentTime {
    self.progressIndicatorLine.frame = CGRectMake(5.0f + currentTime * self.progressUnit, 0.0f, 2.0f, self.collectionView.bounds.size.height);
    
    [self.collectionView scrollRectToVisible:CGRectMake(self.progressIndicatorLine.frame.origin.x, self.progressIndicatorLine.frame.origin.y, self.collectionView.frame.size.width, self.progressIndicatorLine.frame.size.height) animated:YES];
    return ;
}

-(void)videoPlayStatusChanged:(NSNotification*)notification {
    MMVideoPlayStatus status = [[notification.userInfo valueForKey:@"status"] unsignedIntegerValue];
    
    switch (status) {
        case MMVideoPlayStatusStoped:
        {
            self.progressUnit = 0.0f;
            self.progressIndicatorLine.hidden = YES;
            self.progressIndicatorLine.frame = CGRectMake(5.0f, 0.0f, 2.0f, self.collectionView.bounds.size.height);
        }
            break;
        case MMVideoPlayStatusPlaying:
        {
            self.progressIndicatorLine.hidden = NO;
        }
            break;
        default:
            break;
    }
    
    return ;
}

- (void)dealloc
{
    [MMNotificationCenter removeObserver:self];
    return ;
}

@end
