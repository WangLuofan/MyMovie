//
//  MMProjectListCollectionViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//
#import "MMPhotoManager.h"
#import "MMHUDUtils.h"
#import "MMProjectModel.h"
#import "MMProjectListCollectionViewCell.h"
#import "MMProjectEdittingViewController.h"
#import "MMProjectListCollectionViewController.h"

#define kProjectListCollectionViewCellIdentifier @"ProjectListCollectionViewCellIdentifier"
#define kDefaultItemCountPerRow 2
#define kMinimumSpacingInterItem 5

@interface MMProjectListCollectionViewController () <UIGestureRecognizerDelegate>

@property(nonatomic, strong) NSMutableArray* projectList;
@property(nonatomic, strong) NSDateFormatter* dateFormatter;

@end

@implementation MMProjectListCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:nibNamed(@"MMProjectListCollectionViewCell") forCellWithReuseIdentifier:kProjectListCollectionViewCellIdentifier];
    
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressGesture:)];
    longPressGesture.delegate = self;
    [self.collectionView addGestureRecognizer:longPressGesture];
    
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    CGFloat itemWidth = (SCREEN_WIDTH - (kDefaultItemCountPerRow + 1) * kMinimumSpacingInterItem) / kDefaultItemCountPerRow;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.minimumLineSpacing = kMinimumSpacingInterItem;
    flowLayout.minimumInteritemSpacing = kMinimumSpacingInterItem;
    flowLayout.sectionInset = UIEdgeInsetsMake(kMinimumSpacingInterItem, kMinimumSpacingInterItem, 0, kMinimumSpacingInterItem);
    
    _dateFormatter = [[NSDateFormatter alloc] init];
    _dateFormatter.dateFormat = @"YYYY-MM-dd HH:mm:ss";
    
    [self loadProjectListFromProjectDirectory];
    
    return ;
}

-(void)loadProjectListFromProjectDirectory {
    if(_projectList == nil)
        _projectList = [NSMutableArray array];
    
    NSString* docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDirectoryEnumerator* enumerator = [fm enumeratorAtURL:[NSURL fileURLWithPath:docPath] includingPropertiesForKeys:nil options:NSDirectoryEnumerationSkipsSubdirectoryDescendants | NSDirectoryEnumerationSkipsHiddenFiles errorHandler:^BOOL(NSURL * _Nonnull url, NSError * _Nonnull error) {
        if(error != nil) {
            @throw [NSException exceptionWithName:@"EnumError" reason:error.localizedDescription userInfo:nil];
            return NO;
        }
        
        return YES;
    }];
    
    NSURL* projectDir = enumerator.nextObject;
    while(projectDir != nil) {
        NSString* prefPath = [projectDir.path stringByAppendingPathComponent:@"project.pref"];
        
        if([fm fileExistsAtPath:prefPath]) {
            MMProjectModel* projectModel = [NSKeyedUnarchiver unarchiveObjectWithFile:prefPath];
            if(projectModel != nil)
                [_projectList addObject:projectModel];
        }
        
        projectDir = enumerator.nextObject;
    }
    
    [self.collectionView reloadData];
    return ;
}

-(void)editMediaProjectWithTitle:(NSString*)projectTitle {
    
    NSString* dirPath = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingPathComponent:projectTitle];
    if([[NSFileManager defaultManager] fileExistsAtPath:dirPath] == YES) {
        [MMHUDUtils showHUDInView:self.view title:@"项目已经存在,请更换项目名称"];
        return ;
    }
    
    NSError* error = nil;
    [[NSFileManager defaultManager] createDirectoryAtPath:dirPath withIntermediateDirectories:YES attributes:nil error:&error];
    
    if(error != nil) {
        [MMHUDUtils showHUDInView:self.view inMode:MBProgressHUDModeText withTitle:error.localizedDescription];
        return ;
    }else {
        MMProjectModel* project = [[MMProjectModel alloc] init];
        project.projectTitle = projectTitle;
        project.projectDir = dirPath;
        project.projectThumb = nil;
        project.createDate = [_dateFormatter stringFromDate:[NSDate date]];
        project.modifyDate = [project.createDate copy];
        
        BOOL bSuccess = [NSKeyedArchiver archiveRootObject:project toFile:[project.projectDir stringByAppendingPathComponent:@"project.pref"]];
        
        if(bSuccess) {
            [_projectList insertObject:project atIndex:0];
            [self.collectionView performBatchUpdates:^{
                [self.collectionView insertItemsAtIndexPaths:@[[NSIndexPath indexPathForItem:1 inSection:0]]];
            } completion:^(BOOL finished) {
                if(finished) {
                    MMProjectEdittingViewController* edittingController = [[MMProjectEdittingViewController alloc] init];
                    edittingController.title = projectTitle;
                    [self.navigationController pushViewController:edittingController animated:YES];
                }
            }];
        }else {
            UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"创建失败" message:nil preferredStyle:UIAlertControllerStyleAlert];
            [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
            [self.navigationController presentViewController:alertController animated:YES completion:nil];
        }
    }
    return ;
}

- (IBAction)removeAllProjects:(UIBarButtonItem *)sender {
    UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"清空项目" message:@"确定要删除所有项目吗?" preferredStyle:UIAlertControllerStyleAlert];
    [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self performRemoveAllProject];
    }]];
    [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    return ;
}

-(void)performRemoveAllProject {
    NSString* projectDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSDirectoryEnumerator<NSString*> * enumerator = [fileManager enumeratorAtPath:projectDir];
    
    NSString* dirName = [enumerator nextObject];
    NSError* error = nil;
    
    while(dirName != nil) {
        if([fileManager removeItemAtPath:[projectDir stringByAppendingPathComponent:dirName] error:&error] == NO) {
            break;
        }
        
        dirName = [enumerator nextObject];
    }
    
    UIAlertController* alertController = nil;
    if(error == nil) {
        [_projectList removeAllObjects];
        [self.collectionView reloadData];
        
        alertController = [UIAlertController alertControllerWithTitle:@"清空项目" message:@"已删除所有项目" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil]];
    }else {
        alertController = [UIAlertController alertControllerWithTitle:@"清空失败" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil]];
    }
    
    [self.navigationController presentViewController:alertController animated:YES completion:nil];
    return ;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 1 + _projectList.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMProjectListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kProjectListCollectionViewCellIdentifier forIndexPath:indexPath];
    
    if(indexPath.item == 0)
        cell.projectTitleLabel.text = @"创建项目";
    else {
        MMProjectModel* projectModel = [_projectList objectAtIndex:indexPath.item - 1];
        cell.projectTitleLabel.text = projectModel.projectTitle;
        cell.projectImageView.image = [UIImage imageWithContentsOfFile:projectModel.projectThumb];
    }
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if(indexPath.item == 0) {
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"新建项目" message:nil preferredStyle:UIAlertControllerStyleAlert];
        [alertController addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
            textField.placeholder = @"请输入项目名称";
            textField.keyboardType = UIKeyboardTypeAlphabet;
        }];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            dispatch_async(dispatch_get_main_queue(), ^{
                if([MMPhotoManager sharedManager].authorizationStatus != MMAuthorizationStatusAuthorized) {
                    [[MMPhotoManager sharedManager] requestAuthorization:^(MMAuthorizationStatus status) {
                        [self editMediaProjectWithTitle:[alertController.textFields objectAtIndex:0].text];
                    }];
                }else {
                    [self editMediaProjectWithTitle:[alertController.textFields objectAtIndex:0].text];
                }
            });
        }]];
        
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }else {
        MMProjectModel* projectModel = [_projectList objectAtIndex:indexPath.item - 1];
        MMProjectEdittingViewController* edittingController = [[MMProjectEdittingViewController alloc] initNeedLoadProject];
        edittingController.title = projectModel.projectTitle;
        
        [self.navigationController pushViewController:edittingController animated:YES];
    }
    return ;
}

-(void)deleteProejct:(MMProjectModel*)projectModel indexPath:(NSIndexPath*)indexPath {
    NSError* error = nil;
    [[NSFileManager defaultManager] removeItemAtPath:projectModel.projectDir error:&error];
    
    //    if(error == nil) {
    [_projectList removeObject:projectModel];
    [self.collectionView performBatchUpdates:^{
        [self.collectionView deleteItemsAtIndexPaths:@[indexPath]];
    } completion:nil];
    //    }else {
    //        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"删除项目" message:[NSString stringWithFormat:@"删除项目%@失败: %@", projectModel.projectTitle, error.localizedDescription] preferredStyle:UIAlertControllerStyleAlert];
    //        [alertController addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    //
    //        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    //    }
    
    return ;
}

-(void)handleLongPressGesture:(UIGestureRecognizer*)recognizer {
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        CGPoint location = [recognizer locationInView:self.collectionView];
        NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:location];
        
        MMProjectModel* projectModel = [_projectList objectAtIndex:indexPath.item - 1];
        
        UIAlertController* alertController = [UIAlertController alertControllerWithTitle:@"删除项目" message:[NSString stringWithFormat:@"确定删除项目%@?", projectModel.projectTitle] preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
        [alertController addAction:[UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
            [self deleteProejct:projectModel indexPath:indexPath];
            
            return ;
        }]];
        
        [self.navigationController presentViewController:alertController animated:YES completion:nil];
    }
    
    return ;
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    CGPoint location = [gestureRecognizer locationInView:self.collectionView];
    
    NSIndexPath* indexPath = [self.collectionView indexPathForItemAtPoint:location];
    if(indexPath == nil || indexPath.item == 0)
        return NO;
    
    return YES;
}

@end
