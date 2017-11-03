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

-(void)handleAudioMix {
    [_audioModel.inputParams sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        MMAudioMixModel* audioMixModel_1 = (MMAudioMixModel*)obj1;
        MMAudioMixModel* audioMixModel_2 = (MMAudioMixModel*)obj2;
        
        if(audioMixModel_1.timeInterval < audioMixModel_2.timeInterval)
            return NSOrderedAscending;
        else if(audioMixModel_1.timeInterval > audioMixModel_2.timeInterval)
            return NSOrderedDescending;
        return NSOrderedSame;
    }];
    
    //移除开始或结束时间相同的数据
//    [_audioMixArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        MMAudioMixModel* mixModel = (MMAudioMixModel*)obj;
//
//        if(mixModel.endTimeRange - mixModel.startTimeRange < 0.01f)
//            [_audioMixArray removeObject:mixModel];
//    }];
    
    //列表排序
//    [_audioMixArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
//        MMAudioMixModel* audioMixModel_1 = (MMAudioMixModel*)obj1;
//        MMAudioMixModel* audioMixModel_2 = (MMAudioMixModel*)obj2;
//
//        return audioMixModel_1.startTimeRange - audioMixModel_2.startTimeRange;
//    }];
    
    //多于一条数据，拆分交叉数据
//    if(_audioMixArray.count > 1) {
//        for(int i = (int)(_audioMixArray.count - 2); i >= 0; --i) {
//
//            if(_audioMixArray.count == 1)
//                break;
//
//            MMAudioMixModel* audioMixModel_1 = (MMAudioMixModel*)[_audioMixArray objectAtIndex:i];
//            MMAudioMixModel* audioMixModel_2 = (MMAudioMixModel*)[_audioMixArray objectAtIndex:i + 1];
//
//            //A: -----
//            //B:      ------
//            //情况一: A,B没有交叉，不需处理
//            if(audioMixModel_1.endTimeRange < audioMixModel_2.startTimeRange)
//                continue;
//
//            //-----
//            //  -----
//            //情况二: A,B有交叉但不包含，拆分成两组
//            //第一组: As - Bs 取值Aa
//            //第二组: Bs - Be 取值Ba
//
//            if(audioMixModel_1.endTimeRange > audioMixModel_2.startTimeRange && audioMixModel_1.endTimeRange < audioMixModel_2.endTimeRange) {
//                MMAudioMixModel* startMixModel = [[MMAudioMixModel alloc] initWithStart:audioMixModel_1.startTimeRange end:audioMixModel_2.startTimeRange audio:audioMixModel_1.audioLevel];
//                MMAudioMixModel* endMixModel = [[MMAudioMixModel alloc] initWithStart:audioMixModel_2.startTimeRange end:audioMixModel_2.endTimeRange audio:audioMixModel_2.audioLevel];
//
//                [_audioMixArray replaceObjectAtIndex:i withObject:startMixModel];
//                [_audioMixArray replaceObjectAtIndex:i + 1 withObject:endMixModel];
//            }
//
//            //----------
//            //  -----
//            //情况三: A包含B，分情况拆分成两组或三组
//
//            if(audioMixModel_1.endTimeRange >= audioMixModel_2.startTimeRange && audioMixModel_2.endTimeRange <= audioMixModel_1.endTimeRange) {
//                //情况一: A、B起点相同且终点相同
//                //删除一组，指针向后移动一个单位
//
//                if(audioMixModel_1.startTimeRange == audioMixModel_2.startTimeRange && audioMixModel_1.endTimeRange == audioMixModel_2.endTimeRange) {
//                    [_audioMixArray removeObjectAtIndex:i];
//                }
//
//                //情况二: A、B起点相同但终点不同
//                //第一组: Bs - Be 取值Ba
//                //第二组: Be - Ae 取值Aa
//                //数量不变，无需移动指针
//
//                if(audioMixModel_1.startTimeRange == audioMixModel_2.startTimeRange && audioMixModel_1.endTimeRange > audioMixModel_2.endTimeRange) {
//                    MMAudioMixModel* endMixModel = [[MMAudioMixModel alloc] initWithStart:audioMixModel_2.endTimeRange end:audioMixModel_1.endTimeRange audio:audioMixModel_1.audioLevel];
//                    [_audioMixArray replaceObjectAtIndex:i withObject:audioMixModel_2];
//                    [_audioMixArray replaceObjectAtIndex:i + 1 withObject:endMixModel];
//                }
//
//                //情况三: A、B起点不同但终点相同
//                //第一组: As - Bs 取值Aa
//                //第二组: Bs - Be 取值Ba
//                //数量不变，无需移动指针
//
//                if(audioMixModel_1.startTimeRange < audioMixModel_2.startTimeRange && audioMixModel_1.endTimeRange == audioMixModel_2.endTimeRange) {
//                    MMAudioMixModel* startMixModel = [[MMAudioMixModel alloc] initWithStart:audioMixModel_1.startTimeRange end:audioMixModel_2.startTimeRange audio:audioMixModel_1.audioLevel];
//                    [_audioMixArray replaceObjectAtIndex:i withObject:startMixModel];
//                }
//
//                //情况四: A、B起点和终点都不相同
//                //第一组: As - Bs 取值Aa
//                //第二组: Bs - Be 取值Ba
//                //第三组: Be - Ae 取值Aa
//                //向后添加数据，无需要移动指针
//
//                if(audioMixModel_1.startTimeRange < audioMixModel_2.startTimeRange && audioMixModel_1.endTimeRange > audioMixModel_2.endTimeRange) {
//                    MMAudioMixModel* startMixModel = [[MMAudioMixModel alloc] initWithStart:audioMixModel_1.startTimeRange end:audioMixModel_2.startTimeRange audio:audioMixModel_1.audioLevel];
//                    MMAudioMixModel* endMixModel = [[MMAudioMixModel alloc] initWithStart:audioMixModel_2.endTimeRange end:audioMixModel_1.endTimeRange audio:audioMixModel_1.audioLevel];
//
//                    [_audioMixArray replaceObjectAtIndex:i withObject:startMixModel];
//                    [_audioMixArray insertObject:endMixModel atIndex:i + 2];
//                }
//            }
//        }
//    }
    return ;
}

-(void)gotoBack {
    [self resignFirstResponder];
    [self handleAudioMix];
    
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
            startTimeRangeLabel.text = @"时间点";
            [cell.contentView addSubview:startTimeRangeLabel];
            
            UILabel* audioLevelLabel = [[UILabel alloc] init];
            audioLevelLabel.textAlignment = NSTextAlignmentCenter;
            audioLevelLabel.text = @"音量值";
            [cell.contentView addSubview:audioLevelLabel];
            
            [startTimeRangeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.leading.and.top.and.height.mas_equalTo(cell.contentView);
                make.width.mas_equalTo(audioLevelLabel);
            }];
            
            [audioLevelLabel mas_makeConstraints:^(MASConstraintMaker *make) {
                make.trailing.mas_equalTo(cell.contentView);
                make.height.and.top.mas_equalTo(startTimeRangeLabel);
                make.leading.mas_equalTo(startTimeRangeLabel.mas_trailing);
                make.width.mas_equalTo(startTimeRangeLabel);
            }];
        }
    }else {
        cell = [tableView dequeueReusableCellWithIdentifier:kAudioTrackMixModifyTableViewCellIdentifier];
        
        if(cell == nil)
            cell = [[MMAudioMixModifyTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kAudioTrackMixModifyTableViewCellIdentifier];
        
        ((MMAudioMixModifyTableViewCell*)cell).duration = _audioModel.duration;
        ((MMAudioMixModifyTableViewCell*)cell).audioMixModel = [_audioModel.inputParams objectAtIndex:(NSUInteger)indexPath.row];
        
        if(indexPath.row != 0)
            ((MMAudioMixModifyTableViewCell*)cell).previousTimeInterval = ((MMAudioMixModel*)[_audioModel.inputParams objectAtIndex:(NSUInteger)(indexPath.row - 1)]).timeInterval;
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
    
    return @[deleteRowAction];
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self resignFirstResponder];
    return ;
}

@end
