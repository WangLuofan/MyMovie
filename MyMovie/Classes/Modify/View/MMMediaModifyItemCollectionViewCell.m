//
//  MMMediaModifyItemCollectionViewCell.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/19.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMMediaModifyItemCollectionViewCell.h"

@interface MMMediaModifyItemCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *selectionImageView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingLayoutConstraint;

@end

@implementation MMMediaModifyItemCollectionViewCell

-(void)awakeFromNib {
    [super awakeFromNib];
    
    _selectionImageView.image = [[UIImage imageNamed:@"th_trimmer_ui_highlighted"] resizableImageWithCapInsets:UIEdgeInsetsMake(25, 15, 25, 20) resizingMode:UIImageResizingModeStretch];
    return ;
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    
    if(selected) {
        _selectionImageView.hidden = NO;
        
        _topLayoutConstraint.constant = 5.0f;
        _leadingLayoutConstraint.constant = 6.0f;
        _bottomLayoutConstraint.constant = -5.0f;
        _trailingLayoutConstraint.constant = -14.0f;
    }else {
        _selectionImageView.hidden = YES;
        
        _topLayoutConstraint.constant = 0.0f;
        _leadingLayoutConstraint.constant = 0.0f;
        _bottomLayoutConstraint.constant = 0.0f;
        _trailingLayoutConstraint.constant = 0.0f;
    }
    
    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
        [self layoutIfNeeded];
    }];
    return ;
}

-(void)prepareForReuse {
    [super prepareForReuse];
    
    self.contentImageView.image = nil;
    return ;
}

@end
