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

#define nibNamed(nibName) [UINib nibWithNibName:nibName bundle:[NSBundle mainBundle]]
#define storyBoardNamed(sbName) [UIStoryboard storyboardWithName:sbName bundle:[NSBundle mainBundle]]

#endif /* GenericMarcos_h */
