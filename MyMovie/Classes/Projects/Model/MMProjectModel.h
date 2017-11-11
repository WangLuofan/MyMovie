//
//  MMProjectModel.h
//  MyMovie
//
//  Created by 王落凡 on 2017/11/11.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MMProjectModel : NSObject <NSSecureCoding>

@property(nonatomic, copy) NSString* projectTitle;
@property(nonatomic, copy) NSString* projectDir;
@property(nonatomic, copy) NSString* projectThumb;
@property(nonatomic, copy) NSString* createDate;
@property(nonatomic, copy) NSString* modifyDate;

@end
