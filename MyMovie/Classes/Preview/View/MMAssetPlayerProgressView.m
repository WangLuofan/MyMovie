//
//  MMAssetPlayerProgressView.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/28.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMAssetPlayerProgressView.h"

@interface MMAssetPlayerProgressView()

@property(nonatomic, strong) UILabel* progressLabel;
@property(nonatomic, strong) UIImageView* progressImageView;

@end

@implementation MMAssetPlayerProgressView
- (instancetype)init
{
    self = [super init];
    if (self) {
        [self initProgress];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self initProgress];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 50.0f)];
    if (self) {
        [self initProgress];
    }
    return self;
}

-(void)initProgress {
    self.image = [UIImage imageNamed:@"export_progress_track_img"];
    if(_progressImageView == nil) {
        _progressImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"export_progress_img"]];
        _progressImageView.layer.cornerRadius = 15.5f;
        _progressImageView.clipsToBounds = YES;
        [self addSubview:_progressImageView];
    }
    
    if(_progressLabel == nil) {
        _progressLabel = [[UILabel alloc] init];
        _progressLabel.textColor = [UIColor redColor];
        _progressLabel.font = [UIFont systemFontOfSize:12.0f];
        [self addSubview:_progressLabel];
    }
    return ;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    [_progressLabel sizeToFit];
    _progressLabel.center = CGPointMake(self.bounds.size.width / 2, self.bounds.size.height / 2);
    _progressImageView.frame = CGRectMake(9, 0, (self.bounds.size.width - 18) * _progress, 31.0f);
    _progressImageView.center = CGPointMake(_progressImageView.center.x, self.bounds.size.height / 2);
    
    return ;
}

-(void)setFrame:(CGRect)frame {
    return [super setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, 50.0f)];
}

-(void)setProgress:(CGFloat)progress {
    NSAssert(progress >= 0.0f && progress <= 1.0f, @"进度条的值介于0.0 ~ 1.0之间");
    
    _progress = progress;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        _progressLabel.text = [NSString stringWithFormat:@"%.2lf%%", _progress * 100];
        [self setNeedsLayout];
    });
    
    return ;
}

@end

@implementation MMAssetPlayerProgressHostView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.5f];
        _progressView = [[MMAssetPlayerProgressView alloc] init];
        [self addSubview:_progressView];
    }
    return self;
}

-(void)layoutSubviews {
    [super layoutSubviews];
    
    _progressView.frame = CGRectMake(8, 0, self.bounds.size.width - 16, 0);
    _progressView.center = CGPointMake(_progressView.center.x, self.bounds.size.height / 2);
    
    return ;
}

@end
