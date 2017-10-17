//
//  MMPhotosItemCollectionViewCell.h
//  MyMovie
//
//  Created by 王落凡 on 2017/10/12.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MMPhotosItemCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UILabel *durLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;

-(UIImage*)toImage;

@end
