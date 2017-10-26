//
//  MMAudioAssetsTableViewController.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/19.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMMediaAssetsTableViewController.h"

@interface MMAudioAssetsTableViewController : MMMediaAssetsTableViewController

-(void)insertModifyItemAtIndexPath:(NSIndexPath*)indexPath;
-(void)previewItemAtIndexPath:(NSIndexPath *)indexPath;

@end
