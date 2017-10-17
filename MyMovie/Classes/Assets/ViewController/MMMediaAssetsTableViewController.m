//
//  MMMediaAssetsTableViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMHUDUtils.h"
#import "MMPhotoManager.h"
#import "MMImagePickerTableViewCell.h"
#import "MMMediaAssetsTableViewController.h"
#import "MMPhotosCollectionViewController.h"

#define kImagePickerTableViewCellIdentifier @"ImagePickerTableViewCellIdentifier"
@interface MMMediaAssetsTableViewController ()

@property(nonatomic, copy) NSArray* allAlbums;
@property(nonatomic, strong) NSMutableArray* cachedPostImages;

@end

@implementation MMMediaAssetsTableViewController

-(void)awakeFromNib {
    [super awakeFromNib];
    
    _allAlbums = [[MMPhotoManager sharedManager] fetchAllPhotoAlbums];
    return ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerNib:nibNamed(@"MMImagePickerTableViewCell") forCellReuseIdentifier:kImagePickerTableViewCellIdentifier];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStylePlain target:self action:@selector(gotoBack)];
    
    return ;
}

-(void)gotoPhotosAtIndex:(NSInteger)index animated:(BOOL)animated {
    NSArray* assets = [[_cachedPostImages objectAtIndex:index] objectAtIndex:1];
    PHAssetCollection* collection = (PHAssetCollection*)[_allAlbums objectAtIndex:index];
    
    MMPhotosCollectionViewController* photosController = [[MMPhotosCollectionViewController alloc] initWithAssets:assets];
    photosController.title = collection.localizedTitle;
    [self.navigationController pushViewController:photosController animated:animated];
    return ;
}

-(void)gotoBack {
    [self.parentViewController.navigationController popViewControllerAnimated:YES];
    return ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_allAlbums == nil)
        return 0;
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _allAlbums.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    MMImagePickerTableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kImagePickerTableViewCellIdentifier];
    PHAssetCollection* collection = (PHAssetCollection*)[_allAlbums objectAtIndex:indexPath.row];
    
    NSArray* post = nil;
    if(_cachedPostImages != nil && _cachedPostImages.count > indexPath.row) {
        post = [_cachedPostImages objectAtIndex:indexPath.row];
    }else {
        post = [[MMPhotoManager sharedManager] postImageForAlbum:collection targetSize:CGSizeMake(70.0f, 70.0f)];
        if(_cachedPostImages == nil)
            _cachedPostImages = [NSMutableArray array];
        [_cachedPostImages addObject:post];
    }
    
    cell.rollNameLabel.text = collection.localizedTitle;
    if([[post objectAtIndex:0] isEqual:[NSNull null]] == NO)
        cell.imageView.image = (UIImage*)[post objectAtIndex:0];
    else
        cell.imageView.image = nil;
    
    cell.rollItemsLabel.text = [NSString stringWithFormat:@"%ld 项", [[post objectAtIndex:1] count]];
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80.0f;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self gotoPhotosAtIndex:(NSInteger)indexPath.row animated:YES];
    return ;
}

@end
