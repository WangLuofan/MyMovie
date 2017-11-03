//
//  MMAudioMixModifyTableViewCell.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/31.
//  Copyright © 2017年 王落凡. All rights reserved.
//
#import "MMStepView.h"
#import "MMAudioMixModel.h"
#import "NSString+MMDataFormatter.h"
#import "MMAudioMixModifyTableViewCell.h"

@interface MMAudioMixModifyTableViewCell()

@property(nonatomic, strong) MMStepView* timeIntervalStepView;
@property(nonatomic, strong) MMStepView* audioLevelStepView;

@end

@implementation MMAudioMixModifyTableViewCell

-(instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    
    if(self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        [self initUI];
    }
    
    return self;
}

-(void)initUI {
    _timeIntervalStepView = [[MMStepView alloc] initWithKeyboardType:MMStepViewKeyboardTypeDecimal precision:2];
    [_timeIntervalStepView addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    _timeIntervalStepView.stepCount = @"0.01";
    _timeIntervalStepView.minimum = @"0";
    _timeIntervalStepView.placeholder = @"时间点";
    [self.contentView addSubview:_timeIntervalStepView];

    _audioLevelStepView = [[MMStepView alloc] initWithKeyboardType:MMStepViewKeyboardTypeDecimal precision:1];
    _audioLevelStepView.placeholder = @"音量值";
    _audioLevelStepView.stepCount = @"0.1";
    _audioLevelStepView.maximum = @"1.0";
    [_audioLevelStepView addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_audioLevelStepView];

    [_timeIntervalStepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.top.and.height.mas_equalTo(self.contentView);
        make.width.mas_equalTo(_audioLevelStepView);
    }];

    [_audioLevelStepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView);
        make.height.and.top.mas_equalTo(_timeIntervalStepView);
        make.leading.mas_equalTo(_timeIntervalStepView.mas_trailing);
        make.width.mas_equalTo(_timeIntervalStepView);
    }];
    return ;
}

-(void)setAudioMixModel:(MMAudioMixModel *)audioMixModel {
    _audioMixModel = audioMixModel;
    
    _timeIntervalStepView.value = [NSString stringWithFloat:_audioMixModel.timeInterval effectiveBits:2];
    _audioLevelStepView.value = [NSString stringWithFloat:_audioMixModel.audioLevel effectiveBits:1];
    
    return ;
}

-(void)setPreviousTimeInterval:(NSTimeInterval)previousTimeInterval {
    _timeIntervalStepView.minimum = [NSString stringWithFloat:previousTimeInterval effectiveBits:2];
    return ;
}

-(void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    
    _timeIntervalStepView.maximum = [NSString stringWithFloat:_duration effectiveBits:2];
    return ;
}

-(void)valueChanged:(MMStepView*)stepView {
    if([stepView isEqual:_timeIntervalStepView]) {
        _audioMixModel.timeInterval = [stepView.value doubleValue];
    }else {
        _audioMixModel.audioLevel = [stepView.value doubleValue];
    }
    
    return ;
}

@end
