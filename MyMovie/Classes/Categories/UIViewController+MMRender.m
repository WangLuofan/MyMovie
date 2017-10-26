//
//  UIViewController+MMRender.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/26.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "UIView+MMRender.h"
#import "UIViewController+MMRender.h"

@implementation UIViewController (MMRender)

-(UIImageView *)renderItemAtPosition:(CGPoint)point {
    NSIndexPath* indexPath = nil;
    UIImage* oriImage = nil;
    
    if([self isKindOfClass:[UICollectionViewController class]]) {
        indexPath = [((UICollectionViewController*)self).collectionView indexPathForItemAtPoint:point];
        UICollectionViewCell* cell = [((UICollectionViewController*)self).collectionView cellForItemAtIndexPath:indexPath];
        
        oriImage = [cell toImage];
    }
    else if([self isKindOfClass:[UITableViewController class]]) {
        indexPath = [((UITableViewController*)self).tableView indexPathForRowAtPoint:point];
        UITableViewCell* cell = [((UITableViewController*)self).tableView cellForRowAtIndexPath:indexPath];
        
        oriImage = [cell toImage];
    }
    
    return [[UIImageView alloc] initWithImage:oriImage];
}

-(CGRect)itemFrameAtPosition:(CGPoint)point toView:(UIView *)view {
    CGRect itemFrame = CGRectZero;
    NSIndexPath* indexPath = nil;
    
    if([self isKindOfClass:[UICollectionViewController class]]) {
        indexPath = [((UICollectionViewController*)self).collectionView indexPathForItemAtPoint:point];
        UICollectionViewCell* cell = [((UICollectionViewController*)self).collectionView cellForItemAtIndexPath:indexPath];
        
        itemFrame = [((UICollectionViewController*)self).collectionView convertRect:cell.frame toView:view];
    }
    else if([self isKindOfClass:[UITableViewController class]]) {
        indexPath = [((UITableViewController*)self).tableView indexPathForRowAtPoint:point];
        UITableViewCell* cell = [((UITableViewController*)self).tableView cellForRowAtIndexPath:indexPath];
        
        itemFrame = [((UITableViewController*)self).tableView convertRect:cell.frame toView:view];
    }
    
    return itemFrame;
}

-(NSIndexPath *)getItemIndexPathAtPoint:(CGPoint)point {
    NSIndexPath* indexPath = nil;
    
    if([self isKindOfClass:[UICollectionViewController class]]) {
        indexPath = [((UICollectionViewController*)self).collectionView indexPathForItemAtPoint:point];
    }
    else if([self isKindOfClass:[UITableViewController class]]) {
        indexPath = [((UITableViewController*)self).tableView indexPathForRowAtPoint:point];
    }
    
    return indexPath;
}

@end
