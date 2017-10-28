//
//  NSString+MD5.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/28.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "NSString+MD5.h"
#import <CommonCrypto/CommonCrypto.h>

@implementation NSString (MD5)

+(instancetype)md5:(NSString *)srcStr {
    unsigned char md5Str[CC_MD5_DIGEST_LENGTH] = {0};
    CC_MD5(srcStr.UTF8String, (CC_LONG)strlen(srcStr.UTF8String), md5Str);
    
    NSMutableString* result = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH];
    for(int i = 0; i != CC_MD5_DIGEST_LENGTH; ++i)
        [result appendFormat:@"%02x", md5Str[i]];
    
    return [result copy];
}

@end
