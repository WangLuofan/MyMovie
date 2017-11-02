//
//  MMAudioMediaItemCollectionViewCell.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/30.
//  Copyright © 2017年 王落凡. All rights reserved.
//
#import "MMAudioMixModel.h"
#import "MMAudioMediaItemCollectionViewCell.h"

@interface MMAudioMediaItemCollectionViewCell()

@property (weak, nonatomic) IBOutlet UIImageView *selectionImageView;

@end

@implementation MMAudioMediaItemCollectionViewCell

-(void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
    CGContextRef theCtx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(theCtx);
    
    [[UIColor greenColor] setStroke];
    [[UIColor orangeColor] setFill];
    
    CGContextSetLineWidth(theCtx, 1.0f);
    
    if(_inputParams.count == 0) {
        CGContextMoveToPoint(theCtx, 0, 0);
        CGContextAddLineToPoint(theCtx, rect.size.width, 0.0f);
    }
    
    if(_inputParams.count != 0) {
        CGSize itemSize = CGSizeMake(5.0f, rect.size.height);
        
        CGFloat audioLevel = 0.0f;
        CGContextMoveToPoint(theCtx, 0.0f, rect.size.height);
        for(int i = 0; i != _inputParams.count; ++i) {
            MMAudioMixModel* audioMixModel = [_inputParams objectAtIndex:i];
            
            CGContextAddLineToPoint(theCtx, audioMixModel.startTimeRange * itemSize.width, (1 - audioLevel) * itemSize.height);
            CGContextAddLineToPoint(theCtx, audioMixModel.endTimeRange * itemSize.width, (1 - audioMixModel.audioLevel) * itemSize.height);
            audioLevel = audioMixModel.audioLevel;
        }
        
        CGPoint curPoint = CGContextGetPathCurrentPoint(theCtx);
        CGContextAddLineToPoint(theCtx, rect.size.width, curPoint.y);
        CGContextAddLineToPoint(theCtx, rect.size.width, rect.size.height);
    }
    
    CGContextDrawPath(theCtx, kCGPathFillStroke);
    
    CGContextRestoreGState(theCtx);
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
