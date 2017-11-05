//
//  QHStepView.h
//  GoldWorld
//
//  Created by 王落凡 on 2017/4/10.
//  Copyright © 2017年 qhspeed. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, MMStepViewKeyboardType) {
    MMStepViewKeyboardTypeNumber, MMStepViewKeyboardTypeDecimal,
};

@interface MMStepView : UIControl

-(instancetype)initWithPrecision:(NSInteger)precision;
-(instancetype)initWithKeyboardType:(MMStepViewKeyboardType)keyboardType precision:(NSInteger)precision;

@property(nonatomic, copy) NSString* placeholder;
@property(nonatomic, copy) NSString* stepCount;
@property(nonatomic, copy) NSString* value;
@property(nonatomic, assign) NSInteger precision;
@property(nonatomic, copy) NSString* maximum;
@property(nonatomic, copy) NSString* minimum;
@property(nonatomic, assign) MMStepViewKeyboardType keyboardType;

@end
