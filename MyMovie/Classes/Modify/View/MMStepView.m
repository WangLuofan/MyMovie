//
//  QHStepView.m
//  GoldWorld
//
//  Created by 王落凡 on 2017/4/10.
//  Copyright © 2017年 qhspeed. All rights reserved.
//

#import "NSString+MMDataFormatter.h"
#import "MMStepView.h"

@interface MMStepView () <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *valueTextField;
@property (weak, nonatomic) IBOutlet UIButton *increaseBtn;
@property (weak, nonatomic) IBOutlet UIButton *decreaseBtn;

@end

@implementation MMStepView
- (instancetype)init
{
    @throw @"Please Use initWithPrecision or initWithKeyboardType:precision:";
    return nil;
}

- (IBAction)textChanged:(UITextField *)sender {
    for (id target in self.allTargets) {
        NSArray* actions = [self actionsForTarget:target forControlEvent:UIControlEventValueChanged];
        for (NSString* action in actions)
            [target performSelector:NSSelectorFromString(action) withObject:self];
    }
    return ;
}

- (instancetype)initWithPrecision:(NSInteger)precision
{
    self = [self initWithKeyboardType:MMStepViewKeyboardTypeNumber precision:precision];
    
    if(self) {
        
    }
    
    return self;
}

-(instancetype)initWithKeyboardType:(MMStepViewKeyboardType)keyboardType precision:(NSInteger)precision {
    self = [[[NSBundle mainBundle] loadNibNamed:@"MMStepView" owner:nil options:nil] objectAtIndex:0];
    
    if (self) {
        _precision = precision;
        self.keyboardType = keyboardType;
    }
    
    return self;
}

-(NSString *)value {
    if(self.valueTextField.text.length == 0)
        return @"0.00";
    return self.valueTextField.text;
}

-(void)setValue:(NSString *)value {
    NSString* tmpVal = [value copy];
    
    NSDecimalNumber* valueDecimal = [NSDecimalNumber decimalNumberWithString:tmpVal];
    NSDecimalNumber* maxDecimal = [NSDecimalNumber decimalNumberWithString:_maximum];
    NSDecimalNumber* minDecimal = [NSDecimalNumber decimalNumberWithString:_minimum];
    
    if([valueDecimal compare:maxDecimal] == NSOrderedDescending)
        tmpVal = _maximum;
    if([valueDecimal compare:minDecimal] == NSOrderedAscending)
        tmpVal = _minimum;
    
    if(_keyboardType == MMStepViewKeyboardTypeDecimal)
        _valueTextField.text = [NSString correctPrecisionWithString:[[NSDecimalNumber decimalNumberWithString:tmpVal] stringValue] precision:_precision];
    else {
        NSRange pointRange = [tmpVal rangeOfString:@"."];
        
        if(pointRange.location == NSNotFound)
            _valueTextField.text = tmpVal;
        else
            _valueTextField.text = [tmpVal substringToIndex:pointRange.location];
    }
    
    if([tmpVal isEqualToString:_minimum])
        _decreaseBtn.enabled = NO;
    else
        _decreaseBtn.enabled = YES;
    
    if([tmpVal isEqualToString:_maximum])
        _increaseBtn.enabled = NO;
    else
        _increaseBtn.enabled = YES;
    
    return ;
}

-(void)setMaximum:(NSString *)maximum {
    _maximum = maximum;
    
    NSDecimalNumber* value = [NSDecimalNumber decimalNumberWithString:self.value];
    NSDecimalNumber* max = [NSDecimalNumber decimalNumberWithString:_maximum];
    
    if([value compare:max] == NSOrderedAscending)
        _increaseBtn.enabled = YES;
    else
        _increaseBtn.enabled = NO;
    
    return ;
}

-(void)setMinimum:(NSString *)minimum {
    _minimum = minimum;
    
    NSDecimalNumber* value = [NSDecimalNumber decimalNumberWithString:self.value];
    NSDecimalNumber* min = [NSDecimalNumber decimalNumberWithString:_minimum];
    
    if([value compare:min] == NSOrderedDescending)
        _decreaseBtn.enabled = YES;
    else
        _decreaseBtn.enabled = NO;
    
    return ;
}

-(void)setKeyboardType:(MMStepViewKeyboardType)keyboardType {
    _keyboardType = keyboardType;
    
    if(keyboardType == MMStepViewKeyboardTypeNumber)
        self.valueTextField.keyboardType = UIKeyboardTypeNumberPad;
    else
        self.valueTextField.keyboardType = UIKeyboardTypeDecimalPad;
    
    return ;
}

-(void)awakeFromNib {
    [super awakeFromNib];
    
    self.layer.borderColor = UIColorFromRGB(0xF2F3F9).CGColor;
    self.layer.borderWidth = 1.0f;
    self.layer.cornerRadius = 4.0f;
    self.clipsToBounds = YES;
    
    _stepCount = @"1";
    _maximum = [NSString stringWithFormat:@"%lu", ULONG_MAX];
    _minimum = @"0";
    
    return ;
}

-(BOOL)isEnabled {
    return _valueTextField.isEnabled;
}

-(void)setEnabled:(BOOL)enabled {
    _valueTextField.enabled = enabled;
    return ;
}

-(BOOL)resignFirstResponder {
    [_valueTextField resignFirstResponder];
    return [super resignFirstResponder];
}

-(void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    _valueTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0xC8C9CC)}];
}

- (IBAction)decrease {
    NSDecimalNumberHandler* handler = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundPlain scale:_precision raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    self.value = [[[NSDecimalNumber decimalNumberWithString:self.value] decimalNumberBySubtracting:[NSDecimalNumber decimalNumberWithString:self.stepCount] withBehavior:handler] stringValue];
    
    for (id target in self.allTargets) {
        NSArray* actions = [self actionsForTarget:target forControlEvent:UIControlEventValueChanged];
        for (NSString* action in actions)
            [target performSelector:NSSelectorFromString(action) withObject:self];
    }
    
    return ;
}

- (IBAction)increment {
    
    NSDecimalNumberHandler* handler = [[NSDecimalNumberHandler alloc] initWithRoundingMode:NSRoundPlain scale:_precision raiseOnExactness:NO raiseOnOverflow:NO raiseOnUnderflow:NO raiseOnDivideByZero:NO];
    self.value = [[[NSDecimalNumber decimalNumberWithString:self.value] decimalNumberByAdding:[NSDecimalNumber decimalNumberWithString:self.stepCount] withBehavior:handler] stringValue];
    
    for (id target in self.allTargets) {
        NSArray* actions = [self actionsForTarget:target forControlEvent:UIControlEventValueChanged];
        for (NSString* action in actions)
            [target performSelector:NSSelectorFromString(action) withObject:self];
    }
    return ;
}

#pragma mark - UITextFieldDelegate
-(BOOL)textFieldShouldReturn:(UITextField *)textField {
    return YES;
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    if(textField.text.length <= 0) {
        self.value = @"0.00";
    }else {
        
        NSString* text = [textField.text substringToIndex:textField.text.length - 1];
        NSString* last = [textField.text substringFromIndex:textField.text.length - 1];
        
        if([text rangeOfString:@"."].location != NSNotFound && [last isEqualToString:@"."])
            textField.text = text;
    }
    self.value = [[NSDecimalNumber decimalNumberWithString:textField.text] stringValue];
    
    for (id target in self.allTargets) {
        NSArray* actions = [self actionsForTarget:target forControlEvent:UIControlEventValueChanged];
        for (NSString* action in actions)
            [target performSelector:NSSelectorFromString(action) withObject:self];
    }
    return ;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    NSInteger pos = [textField.text rangeOfString:@"."].location;
    
    if((pos != NSNotFound || textField.text.length == 0) && [string isEqualToString:@"."] == YES)
        return NO;
    
    if(pos != NSNotFound) {
        if([string isEqualToString:@""] == YES && range.location == textField.text.length - 1 && range.length == 1)
            return YES;
        
        if(textField.text.length - pos - 1>= _precision)
            return NO;
    }
    
    return YES;
}

@end
