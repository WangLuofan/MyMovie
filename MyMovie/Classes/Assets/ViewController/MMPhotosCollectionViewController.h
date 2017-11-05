//
//  MMPhotosCollectionViewController.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/12.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMBasicCollectionViewController.h"

@interface MMPhotosCollectionViewController : MMBasicCollectionViewController

-(instancetype)initWithAssets:(NSArray*)assets;

-(void)insertModifyItemAtIndexPath:(NSIndexPath*)indexPath;
-(void)previewItemAtIndexPath:(NSIndexPath*)indexPath;

@end
