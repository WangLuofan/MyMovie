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
    _startTimeRangeStepView = [[MMStepView alloc] initWithKeyboardType:MMStepViewKeyboardTypeDecimal precision:2];
    [_startTimeRangeStepView addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    _startTimeRangeStepView.stepCount = @"0.01";
    _startTimeRangeStepView.minimum = @"0.0";
    _startTimeRangeStepView.placeholder = @"起始时间";
    [self.contentView addSubview:_startTimeRangeStepView];
    
    _endTimeRangeStepView = [[MMStepView alloc] initWithKeyboardType:MMStepViewKeyboardTypeDecimal precision:2];
    _endTimeRangeStepView.stepCount = @"0.01";
    _endTimeRangeStepView.minimum = @"0.0";
    _endTimeRangeStepView.placeholder = @"结束时间";
    [_endTimeRangeStepView addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_endTimeRangeStepView];
    
    _audioLevelStepView = [[MMStepView alloc] initWithKeyboardType:MMStepViewKeyboardTypeDecimal precision:1];
    _audioLevelStepView.placeholder = @"音量大小";
    _audioLevelStepView.stepCount = @"0.1";
    _audioLevelStepView.maximum = @"1.0";
    [_audioLevelStepView addTarget:self action:@selector(valueChanged:) forControlEvents:UIControlEventValueChanged];
    [self.contentView addSubview:_audioLevelStepView];
    
    [_startTimeRangeStepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.and.top.and.height.mas_equalTo(self.contentView);
        make.width.mas_equalTo(_endTimeRangeStepView);
    }];
    
    [_endTimeRangeStepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.leading.mas_equalTo(_startTimeRangeStepView.mas_trailing);
        make.top.and.height.mas_equalTo(_startTimeRangeStepView);
        make.width.mas_equalTo(_audioLevelStepView);
    }];
    
    [_audioLevelStepView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.trailing.mas_equalTo(self.contentView);
        make.height.and.top.mas_equalTo(_startTimeRangeStepView);
        make.leading.mas_equalTo(_endTimeRangeStepView.mas_trailing);
        make.width.mas_equalTo(_startTimeRangeStepView);
    }];
    return ;
}

-(void)setAudioMixModel:(MMAudioMixModel *)audioMixModel {
    _audioMixModel = audioMixModel;
    
    _startTimeRangeStepView.value = [NSString stringWithFloat:_audioMixModel.startTimeRange effectiveBits:2];
    _endTimeRangeStepView.value = [NSString stringWithFloat:_audioMixModel.endTimeRange effectiveBits:2];
    _audioLevelStepView.value = [NSString stringWithFloat:_audioMixModel.audioLevel effectiveBits:1];
    
    return ;
}

-(void)setDuration:(NSTimeInterval)duration {
    _duration = duration;
    
    _startTimeRangeStepView.maximum = [NSString stringWithFloat:_duration effectiveBits:2];
    _endTimeRangeStepView.maximum = [NSString stringWithFloat:_duration effectiveBits:2];
    
    return ;
}

-(void)valueChanged:(MMStepView*)stepView {
    if([stepView isEqual:_startTimeRangeStepView]) {
        NSDecimalNumber* startVal = [NSDecimalNumber decimalNumberWithString:stepView.value];
        NSDecimalNumber* endVal = [NSDecimalNumber decimalNumberWithString:_endTimeRangeStepView.value];
        
        _endTimeRangeStepView.minimum = stepView.value;
        
        NSDecimal startDecimal = startVal.decimalValue;
        NSDecimal endDecimal = endVal.decimalValue;
        
        if(NSDecimalCompare(&startDecimal, &endDecimal) == NSOrderedDescending)
            _endTimeRangeStepView.value = stepView.value;
        
        _audioMixModel.startTimeRange = [stepView.value doubleValue];
    }else if([stepView isEqual:_endTimeRangeStepView]) {
        _audioMixModel.endTimeRange = [stepView.value doubleValue];
    }else {
        _audioMixModel.audioLevel = [stepView.value doubleValue];
    }
    
    return ;
}


@end
