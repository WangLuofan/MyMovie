//
//  MMPhotosItemCollectionViewCell.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/12.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPhotosItemCollectionViewCell.h"

@interface MMPhotosItemCollectionViewCell()

@end

@implementation MMPhotosItemCollectionViewCell

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.imageView.image = nil;
    self.durLabel.hidden = YES;
    return ;
}

@end
