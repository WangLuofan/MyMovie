//
//  GenericMarcos.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#ifndef MMGenericMarcos_h
#define MMGenericMarcos_h

#define SCREEN_BOUNDS [UIScreen mainScreen].bounds
#define SCREEN_WIDTH SCREEN_BOUNDS.size.width
#define SCREEN_HEIGHT SCREEN_BOUNDS.size.height

#define kDefaultAnimationDuration 0.25f

#define nibNamed(nibName) [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]]
#define imageNamed(imgName) [UIImage imageNamed:imgName]
#define storyBoardNamed(sbName) [UIStoryboard storyboardWithName:sbName bundle:[NSBundle mainBundle]]
#define App_Delegate ((AppDelegate*)[UIApplication sharedApplication].delegate)

// RGB颜色转换（16进制->10进制）
#define UIColorFromRGB(rgbValue)\
\
[UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 \
alpha:1.0]

#endif /* GenericMarcos_h */
