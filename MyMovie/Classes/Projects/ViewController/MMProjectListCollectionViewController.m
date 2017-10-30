//
//  MMProjectListCollectionViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMPhotoManager.h"
#import "MMHUDUtils.h"
#import "MMProjectListCollectionViewCell.h"
#import "MMProjectEdittingViewController.h"
#import "MMProjectListCollectionViewController.h"

#define kProjectListCollectionViewCellIdentifier @"ProjectListCollectionViewCellIdentifier"
#define kDefaultItemCountPerRow 2
#define kMinimumSpacingInterItem 5

@interface MMProjectListCollectionViewController ()

@end

@implementation MMProjectListCollectionViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.collectionView registerNib:nibNamed(@"MMProjectListCollectionViewCell") forCellWithReuseIdentifier:kProjectListCollectionViewCellIdentifier];
    
    // Do any additional setup after loading the view.
    UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    CGFloat itemWidth = (SCREEN_WIDTH - (kDefaultItemCountPerRow + 1) * kMinimumSpacingInterItem) / kDefaultItemCountPerRow;
    flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
    flowLayout.minimumLineSpacing = kMinimumSpacingInterItem;
    flowLayout.minimumInteritemSpacing = kMinimumSpacingInterItem;
    flowLayout.sectionInset = UIEdgeInsetsMake(kMinimumSpacingInterItem, kMinimumSpacingInterItem, 0, kMinimumSpacingInterItem);
    
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
    }
    
    MMProjectEdittingViewController* edittingController = (MMProjectEdittingViewController*)[storyBoardNamed(@"Main") instantiateViewControllerWithIdentifier:@"MMProjectEdittingViewController"];
    edittingController.title = projectTitle;
    [self.navigationController pushViewController:edittingController animated:YES];
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
        alertController = [UIAlertController alertControllerWithTitle:@"清空项目" message:@"已删除所有项目" preferredStyle:UIAlertControllerStyleAlert];
        [alertController addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleCancel handler:nil]];
    }else {
        alertController = [UIAlertController alertControllerWithTitle:@"清空项目" message:error.localizedDescription preferredStyle:UIAlertControllerStyleAlert];
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
    return 1;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMProjectListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kProjectListCollectionViewCellIdentifier forIndexPath:indexPath];
    
    cell.projectTitleLabel.text = @"创建项目";
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>
-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
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
    return ;
}

@end
