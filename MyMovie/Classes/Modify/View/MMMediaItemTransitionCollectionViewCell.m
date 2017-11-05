//
//  MMMediaItemTransitionCollectionViewCell.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/20.
//  Copyright © 2017年 王落凡. All rights reserved.
//
#import "MMMediaItemModel.h"
#import "MMMediaItemTransitionCollectionViewCell.h"

@interface MMMediaItemTransitionCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIView *selectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *topLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leadingLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomLayoutConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *trailingLayoutConstraint;

@property (weak, nonatomic) IBOutlet UIImageView *transitionImageView;

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

-(void)setTranstionType:(NSUInteger)transtionType {
    _transtionType = transtionType;
    
    switch (_transtionType) {
        case TransitionTypeNone:
            self.transitionImageView.image = [UIImage imageNamed:@"trans_btn_bg_none"];
            break;
        case TransitionTypeCrop:
            self.transitionImageView.image = [UIImage imageNamed:@"trans_btn_bg_xfade"];
            break;
        case TransitionTypePush:
            self.transitionImageView.image = [UIImage imageNamed:@"trans_btn_bg_push"];
            break;
        case TransitionTypeOpacity:
            self.transitionImageView.image = [UIImage imageNamed:@"trans_btn_bg_wipe"];
            break;
    }
    
    return ;
}

@end
