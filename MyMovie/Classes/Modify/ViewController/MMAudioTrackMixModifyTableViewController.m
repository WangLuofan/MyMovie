//
//  MMAudioTrackMixModifyTableViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/31.
//  Copyright © 2017年 王落凡. All rights reserved.
//
#import "MMMediaItemModel.h"
#import "MMAudioMixModel.h"
#import "MMAudioMixModifyTableViewCell.h"
#import "MMAudioTrackMixModifyTableViewController.h"

#define kAudioTrackMixModifyTableViewHeaderCellIdentifier @"AudioTrackMixModifyTableViewHeaderCellIdentifier"
#define kAudioTrackMixModifyTableViewCellIdentifier @"AudioTrackMixModifyTableViewCellIdentifier"

@interface MMAudioTrackMixModifyTableViewController () <UIScrollViewDelegate>

@end

@implementation MMAudioTrackMixModifyTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"音轨编辑";
    
    [self.tableView registerClass:[MMAudioMixModifyTableViewCell class] forCellReuseIdentifier:kAudioTrackMixModifyTableViewCellIdentifier];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(gotoBack)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addParamLine)];
    return ;
}

-(void)addParamLine {
    if(_audioModel != nil) {
        [_audioModel.inputParams addObject:[[MMAudioMixModel alloc] init]];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_audioModel.inputParams.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    return ;
}

-(void)modify {
    return ;
}

-(void)gotoBack {
    [self resignFirstResponder];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    return ;
}

-(BOOL)resignFirstResponder {
    for (UITableViewCell* cell in self.tableView.visibleCells) {
        if([cell isKindOfClass:[MMAudioMixModifyTableViewCell class]]) {
            for (UIView* stepView in cell.contentView.subviews) {
                [stepView resignFirstResponder];
            }
        }
    }
    return [super resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if(_audioModel == nil)
        return 1;
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 1;
    return _audioModel.inputParams.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = nil;
    
    if(indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:kAudioTrackMixModifyTableViewHeaderCellIdentifier];
        if(cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAudioTrackMixModifyTableViewHeaderCellIdentifier];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            UILabel* startTimeRangeLabel = [[UILabel alloc] init];
            startTimeRangeLabel.textAlignment = NSTextAlignmentCenter;
            startTimeRangeLabel.text = @"起始时间";
            [cell.contentView addSubview:startTimeRangeLabel];
            
            UILabel* endTimeRangeLabel = [[UILabel alloc] init];
            endTimeRangeLabel.textAlignment = NSTextAlignmentCenter;
            endTimeRangeLabel.text = @"结束时间";
            [cell.contentView addSubview:endTimeRangeLabel];
            
            UILabel* audioLevelLabel = [[UILabel alloc] init];
            audioLevelLabel.textAlignment = NSTextAlignmentCenter;
            audioLevelLabel.text = @"音量大小";
            [cell.contentView addSubview:audioLevelLabel];
            
            [startTimeRangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.and.top.and.height.mas_equalTo(cell.contentView);
                make.width.mas_equalTo(endTimeRangeLabel);
            }];
            
            [endTimeRangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.mas_equalTo(startTimeRangeLabel.mas_trailing);
                make.top.and.height.mas_equalTo(startTimeRangeLabel);
                make.width.mas_equalTo(audioLevelLabel);
            }];
            
            [audioLevelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(cell.contentView);
                make.height.and.top.mas_equalTo(startTimeRangeLabel);
                make.leading.mas_equalTo(endTimeRangeLabel.mas_trailing);
                make.width.mas_equalTo(startTimeRangeLabel);
            }];
        }
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:kAudioTrackMixModifyTableViewCellIdentifier];
        
        ((MMAudioMixModifyTableViewCell*)cell).duration = _audioModel.duration;
        ((MMAudioMixModifyTableViewCell*)cell).audioMixModel = [_audioModel.inputParams objectAtIndex:(NSUInteger)indexPath.row];
    }
    
    return cell;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
        return 44.0f;
    return 40.0f;
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
        return NO;
    return YES;
}

-(BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    return NO;
}

-(NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0)
        return nil;
    
    UITableViewRowAction* deleteRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleDestructive title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [_audioModel.inputParams removeObjectAtIndex:(NSUInteger)indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    UITableViewRowAction* insertRowAction = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"增加" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        [_audioModel.inputParams addObject:[[MMAudioMixModel alloc] init]];
        [tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_audioModel.inputParams.count - 1 inSection:indexPath.section]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    return @[deleteRowAction, insertRowAction];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self resignFirstResponder];
    return ;
}

@end
