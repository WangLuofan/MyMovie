//
//  MMMediaItemTransitionCollectionViewCell.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/20.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMMediaItemTransitionCollectionViewCell.h"

@interface MMMediaItemTransitionCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *selectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingLayoutConstraint;

@end

@implementation MMMediaItemTransitionCollectionViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    return ;
}

-(void)setSelected:(BOOL)selected {
    [super setSelected:selected];
    if(selected == YES) {
        _selectionView.hidden = NO;
        _topLayoutConstraint.constant = 2.0f;
        _leadingLayoutConstraint.constant = 2.0f;
        _bottomLayoutConstraint.constant = -2.0f;
        _trailingLayoutConstraint.constant = -2.0f;
    }else {
        _selectionView.hidden = YES;
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

@end
