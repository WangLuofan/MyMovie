//
//  MMMediaPreviewViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import <Photos/Photos.h>
#import "MMMediaPreviewViewController.h"

@interface MMMediaPreviewViewController ()

@property(nonatomic, strong) UIImageView* previewImageView;

@end

@implementation MMMediaPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    return ;
}

-(void)setMediaAsset:(PHAsset *)mediaAsset {
    _mediaAsset = mediaAsset;
    
    if(_mediaAsset.mediaType == PHAssetMediaTypeImage) {
        if(_previewImageView == nil) {
            _previewImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
            [self.view addSubview:_previewImageView];
        }
    }else if(_mediaAsset.mediaType == PHAssetMediaTypeVideo) {
        
    }
    
    return ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
