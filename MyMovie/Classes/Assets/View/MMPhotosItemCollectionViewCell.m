//
//  MMPhotosItemCollectionViewCell.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/12.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPhotosItemCollectionViewCell.h"

@interface MMPhotosItemCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *selectionView;

@end

@implementation MMPhotosItemCollectionViewCell

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    _selectionView.hidden = !selected;
    
    return ;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.durLabel.hidden = YES;
    return ;
}

@end
