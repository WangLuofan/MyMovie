//
//  MMTransitionModifyView.m
//  MyMovie
//
//  Created by 王落凡 on 2017/10/21.
//  Copyright © 2017年 王落凡. All rights reserved.
//

#import "MMMediaItemModel.h"
#import "MMTransitionModifyView.h"
#import "MMMediaItemTransitionCollectionViewCell.h"

#define kMediaItemTransitionCollectionViewCellIdentifier @"MediaItemTransitionCollectionViewCellIdentifier"
@interface MMTransitionModifyView() <UICollectionViewDelegate, UICollectionViewDataSource>

@property(nonatomic, strong) UIView* dimView;
@property(nonatomic, assign) NSInteger theSelectedIndex;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *durBtnsCollection;

@end

@implementation MMTransitionModifyView

-(void)awakeFromNib {
    [super awakeFromNib];
    
    [self.collectionView registerNib:nibNamed(@"MMMediaItemTransitionCollectionViewCell") forCellWithReuseIdentifier:kMediaItemTransitionCollectionViewCellIdentifier];
    
    UICollectionViewFlowLayout* flowLayout = (UICollectionViewFlowLayout*)self.collectionView.collectionViewLayout;
    flowLayout.minimumLineSpacing = 1.0f;
    flowLayout.minimumInteritemSpacing = 1.0f;
    flowLayout.itemSize = CGSizeMake(30.0f, 30.0f);
    
    return ;
}

-(void)setTheSelectedIndex:(NSInteger)theSelectedIndex {
    _theSelectedIndex = theSelectedIndex;
    
    for(UIButton* btn in _durBtnsCollection) {
        if(btn.tag == _theSelectedIndex)
            btn.selected = YES;
        else
            btn.selected = NO;
    }
    
    return ;
}

- (IBAction)secondsSelected:(UIButton *)sender {
    self.theSelectedIndex = sender.tag;
    return ;
}

-(void)showInView:(UIView *)inView withModel:(MMMediaItemModel *)model {
    if(_dimView == nil) {
        _dimView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_HEIGHT, SCREEN_WIDTH)];
        _dimView.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.25f];
    }
    
    self.frame = CGRectMake(0, SCREEN_WIDTH, SCREEN_HEIGHT, 66.0f);
    [_dimView addSubview:self];
    [inView addSubview:_dimView];
    
    self.theSelectedIndex = (NSInteger)(model.duration / 0.5f);
    [self.collectionView selectItemAtIndexPath:[NSIndexPath indexPathForItem:((MMMediaTransitionModel*)model).transitionType inSection:0] animated:YES scrollPosition:UICollectionViewScrollPositionNone];
    
    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
        self.frame = CGRectMake(0, SCREEN_WIDTH - 66.0f, SCREEN_HEIGHT, 66.0f);
    }];
    return ;
}

-(IBAction)hide {
    
    if([self.delegate respondsToSelector:@selector(transitionViewDidHide:)])
        [self.delegate transitionViewDidHide:self];
    
    [UIView animateWithDuration:kDefaultAnimationDuration animations:^{
        self.frame = CGRectMake(0, SCREEN_WIDTH, SCREEN_HEIGHT, 66.0f);
    } completion:^(BOOL finished) {
        if(finished) {
            [self removeFromSuperview];
            [_dimView removeFromSuperview];
        }
    }];
    
    return ;
}

- (IBAction)saveData:(UIButton *)sender {
    MMMediaTransitionModel* model = [[MMMediaTransitionModel alloc] init];
    model.duration = self.theSelectedIndex * 0.5f;
    model.transitionType = [[self.collectionView indexPathsForSelectedItems] objectAtIndex:0].item;
    
    if([self.delegate respondsToSelector:@selector(transitionView:willSaveDataWithModel:)])
        [self.delegate transitionView:self willSaveDataWithModel:model];
    
    [self hide];
    return ;
}

#pragma mark - UICollectionViewDelegate & UICollectionViewDataSource
-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 4;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    MMMediaItemTransitionCollectionViewCell* cell = (MMMediaItemTransitionCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:kMediaItemTransitionCollectionViewCellIdentifier forIndexPath:indexPath];
    if(indexPath.item == 0)
        cell.transitionImageView.image = imageNamed(@"trans_btn_bg_none");
    else if(indexPath.item == 1)
        cell.transitionImageView.image = imageNamed(@"trans_btn_bg_push");
    else if(indexPath.item == 2)
        cell.transitionImageView.image = imageNamed(@"trans_btn_bg_wipe");
    else
        cell.transitionImageView.image = imageNamed(@"trans_btn_bg_xfade");
    return cell;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    return ;
}

@end
