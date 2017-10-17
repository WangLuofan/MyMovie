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
@property (weak, nonatomic) IBOutlet UIButton *mediaAddBtn;

@end

@implementation MMPhotosItemCollectionViewCell

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if(selected == YES) {
        _selectionView.hidden = NO;
        _mediaAddBtn.hidden = NO;
    }else {
        _selectionView.hidden = YES;
        _mediaAddBtn.hidden = YES;
    }
    
    return ;
}

-(UIImage*)toImage {
    UIGraphicsBeginImageContext(self.bounds.size);
    
    [self.layer renderInContext:UIGraphicsGetCurrentContext()];
    
    UIImage* cellImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return cellImg;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.mediaAddBtn.hidden = YES;
    self.durLabel.hidden = YES;
    return ;
}

@end
