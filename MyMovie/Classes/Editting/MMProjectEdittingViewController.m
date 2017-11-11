//
//  MMProjectEdittingViewController.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/16.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMBasicNavigationController.h"
#import "MMProjectEdittingViewController.h"
#import "MMMediaPreviewViewController.h"
#import "MMMediaModifyCollectionViewController.h"
#import "MMPhotosCollectionViewController.h"
#import "MMAudioAssetsTableViewController.h"
#import "MMAudioTrackMixModifyTableViewController.h"
#import "MMPhotoManager.h"
#import "MMTimerManager.h"
#import "MMPopMenu.h"
#import "UIViewController+MMRender.h"

typedef NS_ENUM(NSUInteger, ItemDragStatus) {
    ItemDragStatusUnknown,
    ItemDragStatusForPreview,
    ItemDragStatusForModify,
};

@interface MMProjectEdittingViewController () <UIGestureRecognizerDelegate, MMPopMenuDelegate>

@property(nonatomic, weak) MMMediaModifyCollectionViewController* modifyViewController;
@property(nonatomic, weak) MMMediaPreviewViewController* previewViewController;
@property(nonatomic, weak) MMPhotosCollectionViewController* photosViewController;
@property(nonatomic, weak) MMAudioAssetsTableViewController* audioAssetsViewController;

@property(nonatomic, assign) MMAssetMediaType theSelectedMediaType;
@property(nonatomic, strong) UIImageView* draggleImageView;
@property(nonatomic, assign) ItemDragStatus dragStatus;
@property(nonatomic, copy) NSIndexPath* theSelectedIndexPath;

@property(nonatomic, strong) MMPopMenu* popMenu;
@property(nonatomic, assign) UIInterfaceOrientation orientation;

@property(nonatomic, assign) BOOL bNeedLoadProject;

@end

@implementation MMProjectEdittingViewController

- (instancetype)init
{
    self = (MMProjectEdittingViewController*)[storyBoardNamed(@"Main") instantiateViewControllerWithIdentifier:@"MMProjectEdittingViewController"];
    if (self) {
        _bNeedLoadProject = NO;
    }
    return self;
}

-(instancetype)initNeedLoadProject {
    self = (MMProjectEdittingViewController*)[storyBoardNamed(@"Main") instantiateViewControllerWithIdentifier:@"MMProjectEdittingViewController"];
    if (self) {
        _bNeedLoadProject = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self makeRotate:UIInterfaceOrientationLandscapeLeft];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationChanged:) name:UIDeviceOrientationDidChangeNotification object:nil];
    
    _previewViewController = [self.childViewControllers objectAtIndex:1];
    _modifyViewController = [self.childViewControllers objectAtIndex:2];
    
    UILongPressGestureRecognizer* longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPressAction:)];
    longPressGesture.delegate = self;
    [self.view addGestureRecognizer:longPressGesture];
    
    UIPanGestureRecognizer* panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGestureAction:)];
    panGesture.delegate = self;
    [self.view addGestureRecognizer:panGesture];
    
    if(_bNeedLoadProject == YES)
        [_modifyViewController load];
    return ;
}

-(void)showMenu:(UIButton*)sender {
    if(_popMenu == nil)
        _popMenu = [[MMPopMenu alloc] initWithDelegate:self];
    [_popMenu showInView:sender orientation:_orientation];
    return ;
}

-(void)gotoBack {
    [[MMTimerManager sharedManager] removeAllTimers];
    
    [_modifyViewController save];
    
    [self.navigationController popViewControllerAnimated:YES];
    return ;
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self makeRotate:UIInterfaceOrientationLandscapeLeft];
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    return ;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self makeRotate:UIInterfaceOrientationPortrait];
    [self.navigationController setNavigationBarHidden:NO animated:animated];
    return ;
}

-(MMPhotosCollectionViewController *)photosViewController {
    UITabBarController* tabbarController = [self.childViewControllers objectAtIndex:0];
    MMBasicNavigationController* navController = [((MMBasicNavigationController*)tabbarController).childViewControllers objectAtIndex:0];
    
    return (MMPhotosCollectionViewController*)navController.topViewController;
}

-(MMAudioAssetsTableViewController *)audioAssetsViewController {
    UITabBarController* tabbarController = [self.childViewControllers objectAtIndex:0];
    MMBasicNavigationController* navController = [((MMBasicNavigationController*)tabbarController).childViewControllers objectAtIndex:1];
    
    return (MMAudioAssetsTableViewController*)navController.topViewController;
}

-(void)handlePanGestureAction:(UIGestureRecognizer*)recognizer {
    
    if(recognizer.state == UIGestureRecognizerStateBegan || recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint location = [((UIPanGestureRecognizer*)recognizer) translationInView:self.view];
        _draggleImageView.center = CGPointMake(_draggleImageView.center.x + location.x, _draggleImageView.center.y + location.y);
        
        CGPoint locInModifyVC = [self.view convertPoint:[recognizer locationInView:self.view] toView:_modifyViewController.view];
        CGPoint locInPreviewVC = [self.view convertPoint:[recognizer locationInView:self.view] toView:_previewViewController.view];
        
        if(CGRectContainsPoint(_modifyViewController.collectionView.frame, locInModifyVC)) {
            _draggleImageView.layer.borderWidth = 5.0f;
            _dragStatus = ItemDragStatusForModify;
        }else if(CGRectContainsPoint(_previewViewController.view.frame, locInPreviewVC)) {
            _draggleImageView.layer.borderWidth = 5.0f;
            _dragStatus = ItemDragStatusForPreview;
        }else {
            _draggleImageView.layer.borderWidth = 0.0f;
            _dragStatus = ItemDragStatusUnknown;
        }
        
        [((UIPanGestureRecognizer*)recognizer) setTranslation:CGPointZero inView:self.view];
    }else if(recognizer.state == UIGestureRecognizerStateEnded) {
        _draggleImageView.layer.borderWidth = 0.0f;
        
        if(_dragStatus == ItemDragStatusForPreview) {
            //预览
            if(_theSelectedMediaType == MMAssetMediaTypeVideo) {
                [self.photosViewController previewItemAtIndexPath:_theSelectedIndexPath];
            }else if(_theSelectedMediaType == MMAssetMediaTypeAudio) {
                [self.audioAssetsViewController previewItemAtIndexPath:_theSelectedIndexPath];
            }
            
        }else if(_dragStatus == ItemDragStatusForModify) {
            //编辑
            if(_theSelectedMediaType == MMAssetMediaTypeVideo) {
                [self.photosViewController insertModifyItemAtIndexPath:_theSelectedIndexPath];
            }else if(_theSelectedMediaType == MMAssetMediaTypeAudio) {
                [self.audioAssetsViewController insertModifyItemAtIndexPath:_theSelectedIndexPath];
            }
        }
        
        _dragStatus = ItemDragStatusUnknown;
        
        _theSelectedMediaType = MMAssetMediaTypeUnknown;
        _theSelectedIndexPath = nil;
        
        [_draggleImageView removeFromSuperview];
        _draggleImageView = nil;
    }
    return ;
}

-(void)handleLongPressAction:(UIGestureRecognizer*)recognizer {
    UITabBarController* tabbarController = [self.childViewControllers objectAtIndex:0];
    MMBasicNavigationController* selectedController = (MMBasicNavigationController*)tabbarController.selectedViewController;
    UIViewController* viewController = selectedController.topViewController;
    
    if(recognizer.state == UIGestureRecognizerStateBegan) {
        if(viewController != nil) {
            CGPoint location = CGPointZero;
            
            if([viewController isKindOfClass:[UICollectionViewController class]]) {
                location = [recognizer locationInView:((UICollectionViewController*)viewController).collectionView];
                ((UICollectionViewController*)viewController).collectionView.scrollEnabled = NO;
                _theSelectedMediaType = MMAssetMediaTypeVideo;
            }
            else if([viewController isKindOfClass:[UITableViewController class]]) {
                location = [recognizer locationInView:((UITableViewController*)viewController).tableView];
                ((UITableViewController*)viewController).tableView.scrollEnabled = NO;
                _theSelectedMediaType = MMAssetMediaTypeAudio;
            }
            
            _draggleImageView = [viewController renderItemAtPosition:location];
            _draggleImageView.alpha = 0.5f;
            _draggleImageView.frame = [viewController itemFrameAtPosition:location toView:self.view];
            _draggleImageView.layer.borderColor = [[UIColor yellowColor] CGColor];
            
            _theSelectedIndexPath = [viewController getItemIndexPathAtPoint:location];
            [self.view addSubview:_draggleImageView];
        }
    }else if(recognizer.state == UIGestureRecognizerStateEnded) {
        if([viewController isKindOfClass:[UICollectionViewController class]]) {
            ((UICollectionViewController*)viewController).collectionView.scrollEnabled = YES;
        }
        else if([viewController isKindOfClass:[UITableViewController class]]) {
            ((UITableViewController*)viewController).tableView.scrollEnabled = YES;
        }
        
        [_draggleImageView removeFromSuperview];
        _draggleImageView = nil;
    }
    
    return ;
}

-(void)makeRotate:(UIInterfaceOrientation)orientation {
    if(orientation == UIInterfaceOrientationPortrait) {
        self.navigationController.view.transform = CGAffineTransformIdentity;
    }else if(orientation == UIInterfaceOrientationLandscapeLeft) {
        self.navigationController.view.transform = CGAffineTransformMakeRotation(M_PI_2);
    }else if(orientation == UIInterfaceOrientationLandscapeRight) {
        self.navigationController.view.transform = CGAffineTransformMakeRotation(-M_PI_2);
    }
    
    _orientation = orientation;
    self.navigationController.view.frame = SCREEN_BOUNDS;
    return ;
}

-(void)deviceOrientationChanged:(NSNotification*)notification {
    NSTimeInterval animateDuration = [UIApplication sharedApplication].statusBarOrientationAnimationDuration;
    UIDeviceOrientation deviceOri = ((UIDevice*)notification.object).orientation;
    
    if(UIDeviceOrientationIsLandscape(deviceOri) == NO)
        return ;
    
    [UIView animateWithDuration:animateDuration animations:^{
        if(deviceOri == UIDeviceOrientationLandscapeLeft)
            [self makeRotate:UIInterfaceOrientationLandscapeLeft];
        else
            [self makeRotate:UIInterfaceOrientationLandscapeRight];
    }];
    
    return ;
}

-(BOOL)prefersStatusBarHidden {
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - UIGestureRecognizerDelegate
-(BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    UITabBarController* tabbarController = [self.childViewControllers objectAtIndex:0];
    MMBasicNavigationController* viewController = (MMBasicNavigationController*)tabbarController.selectedViewController;
    
    if(tabbarController.selectedIndex == 0) {
        if([viewController.topViewController isKindOfClass:[UITableViewController class]] == YES)
            return NO;
    }
    
    CGPoint location = [gestureRecognizer locationInView:viewController.view];
    if(CGRectContainsPoint(viewController.view.bounds, location) == false)
        return NO;
    
    return YES;
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if([gestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]] && [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]])
        return NO;
    return YES;
}

#pragma mark - MMPopMenuDelegate
-(NSInteger)numberOfTracks {
    return _modifyViewController.audioDataSource.count;
}

-(NSArray*)itemsForMenu:(MMPopMenu *)popMenu {
    return @[@"加载原音轨"];
}

-(void)popMenu:(MMPopMenu *)popMenu itemSelectedAtIndexPath:(NSIndexPath *)indexPath bTrack:(BOOL)bTrack {
    if(bTrack == YES) {
        MMMediaItemModel* itemModel = [_modifyViewController.audioDataSource objectAtIndex:(NSUInteger)indexPath.row];
        MMAudioTrackMixModifyTableViewController* mixController = [[MMAudioTrackMixModifyTableViewController alloc] initWithModifyViewController:_modifyViewController];
        mixController.audioModel = (MMMediaAudioModel*)itemModel;
        [self.navigationController presentViewController:[[MMBasicNavigationController alloc] initWithRootViewController:mixController] animated:YES completion:nil];
    }else {
        if(indexPath.row == 0) {
            
        }
    }
    return ;
}

-(BOOL)popMenu:(MMPopMenu *)popMenu itemEnableAtIndexPath:(NSIndexPath *)indexPath bTrack:(BOOL)bTrack {
    if(bTrack == NO) {
        if(indexPath.row == 0)
            return _modifyViewController.assetsDataSource.count > 0;
    }
    
    return YES;
}

@end
