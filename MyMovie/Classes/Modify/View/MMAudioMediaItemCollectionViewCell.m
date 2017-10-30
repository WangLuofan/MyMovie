//
//  MMAudioMediaItemCollectionViewCell.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/30.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMAudioMediaItemCollectionViewCell.h"

@interface MMAudioMediaItemCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *selectionImageView;

@end

@implementation MMAudioMediaItemCollectionViewCell

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    return ;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    _selectionImageView.image = [[UIImage imageNamed:@"th_trimmer_ui_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 15, 25, 20) resizingMode:UIImageResizingModeStretch];
    return ;
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if(selected) {
        _selectionImageView.hidden = NO;
    }else {
        _selectionImageView.hidden = YES;
    }
    
    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
        [self layoutIfNeeded];
    }];
    return ;
}

@end
