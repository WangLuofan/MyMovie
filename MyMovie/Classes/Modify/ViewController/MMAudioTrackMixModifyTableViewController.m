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
#import "MMMediaModifyCollectionViewController.h"
#import "MMAudioTrackMixModifyTableViewController.h"

#define kAudioTrackMixModifyTableViewHeaderCellIdentifier @"AudioTrackMixModifyTableViewHeaderCellIdentifier"
#define kAudioTrackMixModifyTableViewCellIdentifier @"AudioTrackMixModifyTableViewCellIdentifier"

@interface MMAudioTrackMixModifyTableViewController () <UIScrollViewDelegate>

@property(nonatomic, weak) MMMediaModifyCollectionViewController* modifyViewController;
@property(nonatomic, strong) NSMutableArray* audioMixArray;

@end

@implementation MMAudioTrackMixModifyTableViewController

- (instancetype)initWithModifyViewController:(MMMediaModifyCollectionViewController *)viewController
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    if (self) {
        _modifyViewController = viewController;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"音轨编辑";
    
    _audioMixArray = [_audioModel.inputParams mutableCopy];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(gotoBack)];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addParamLine)];
    return ;
}

-(void)addParamLine {
    if(_audioModel != nil) {
        [_audioMixArray addObject:[[MMAudioMixModel alloc] init]];
        [self.tableView insertRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:_audioMixArray.count - 1 inSection:1]] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    return ;
}

-(void)gotoBack {
    [self resignFirstResponder];
    
    //移除
    [_audioMixArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        MMAudioMixModel* mixModel = (MMAudioMixModel*)obj;
        
        if(mixModel.startTimeRange == mixModel.endTimeRange)
            [_audioMixArray removeObject:mixModel];
    }];
    
//    [_audioMixArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//
//    }];
    
    [self.navigationController dismissViewControllerAnimated:YES completion:^{
        for(int i = 0; i != _modifyViewController.audioDataSource.count; ++i) {
            if([[_modifyViewController.audioDataSource objectAtIndex:i] isEqual:_audioModel]) {
                [_modifyViewController reloadAudioTrackAtIndex:i];
                break;
            }
        }
    }];
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
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if(section == 0)
        return 1;
    return _audioMixArray.count;
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
        
        if(cell == nil)
            cell = [[MMAudioMixModifyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAudioTrackMixModifyTableViewCellIdentifier];
        
        ((MMAudioMixModifyTableViewCell*)cell).duration = _audioModel.duration;
        ((MMAudioMixModifyTableViewCell*)cell).audioMixModel = [_audioMixArray objectAtIndex:(NSUInteger)indexPath.row];
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
        [_audioMixArray removeObjectAtIndex:(NSUInteger)indexPath.row];
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
    }];
    
    return @[deleteRowAction];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.01f;
}

-(CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    if(section == 0)
        return 0.01f;
    return 80.0f;
}

-(NSString*)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section {
    if(section == 1)
        return @"应用程序会根据实际需要,对您输入的数据进行重新排序、拆分、合并、删除";
    return nil;
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self resignFirstResponder];
    return ;
}

@end
