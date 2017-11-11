//
//  MMProjectModel.m
//  MyMovie
//
//  Created by 王落凡 on 2017/11/11.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMProjectModel.h"

@implementation MMProjectModel
@dynamic supportsSecureCoding;

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    if (self) {
        _projectTitle = [coder decodeObjectForKey:@"ProjectTitle"];
        _projectDir = [coder decodeObjectForKey:@"ProjectDir"];
        _projectThumb = [coder decodeObjectForKey:@"ProjectThumb"];
        _createDate = [coder decodeObjectForKey:@"CreateDate"];
        _modifyDate = [coder decodeObjectForKey:@"ModifyDate"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:_projectTitle forKey:@"ProjectTitle"];
    [coder encodeObject:_projectDir forKey:@"ProjectDir"];
    [coder encodeObject:_projectThumb forKey:@"ProjectThumb"];
    [coder encodeObject:_createDate forKey:@"CreateDate"];
    [coder encodeObject:_modifyDate forKey:@"ModifyDate"];
    
    return ;
}

+(BOOL)supportsSecureCoding {
    return YES;
}

@end
