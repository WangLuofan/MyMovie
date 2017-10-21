//
//  MMAudioAssetsTableViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/19.
//  Copyright © 2017年 王落凡. All rights reserved.
//
#import "MMMediaItemModel.h"
#import "MMPhotoManager.h"
#import <MediaPlayer/MediaPlayer.h>
#import "MMAudioAssetsTableViewController.h"
#import "MMMediaModifyCollectionViewController.h"

#define kAudioAssetsTableViewCellIdentifier @"AudioAssetsTableViewCellIdentifier"
@interface MMAudioAssetsTableViewController ()

@property(nonatomic, copy) NSArray* musicItemsArray;
@property(nonatomic, weak) MMMediaModifyCollectionViewController* modifyViewController;

@end

@implementation MMAudioAssetsTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if([MPMediaLibrary authorizationStatus] != MPMediaLibraryAuthorizationStatusAuthorized) {
        [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
            if(status == MPMediaLibraryAuthorizationStatusAuthorized) {
                [self queryMusicList];
            }
        }];
    }else
        [self queryMusicList];
    
    return ;
}

-(void)queryMusicList {
    
    MPMediaQuery *everything = [[MPMediaQuery alloc] init];
    _musicItemsArray = [everything items];
    
    [self.tableView reloadData];
    return ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _musicItemsArray.count;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:kAudioAssetsTableViewCellIdentifier];
    if(cell == nil)
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kAudioAssetsTableViewCellIdentifier];
    MPMediaItem* mediaItem = [_musicItemsArray objectAtIndex:(NSUInteger)indexPath.row];
    
    cell.textLabel.text = mediaItem.title;
    cell.detailTextLabel.text = mediaItem.artist;
    
    UIButton* addBtn = [UIButton buttonWithType:UIButtonTypeContactAdd];
    cell.accessoryView = addBtn;
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if(_modifyViewController == nil)
        _modifyViewController = [self.navigationController.parentViewController.parentViewController.childViewControllers objectAtIndex:2];
    
    MPMediaItem* mediaItem = [_musicItemsArray objectAtIndex:(NSUInteger)indexPath.row];
    MMMediaAudioModel* audioModel = [[MMMediaAudioModel alloc] init];
    
    audioModel.mediaType = MMAssetMediaTypeAudio;
    audioModel.title = mediaItem.title;
    audioModel.artist = mediaItem.artist;
    audioModel.mediaAsset = [AVAsset assetWithURL:mediaItem.assetURL];
    
    [_modifyViewController insertItemWithMediaItemModel:audioModel];
    return ;
}

@end
