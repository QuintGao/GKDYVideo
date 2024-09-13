//
//  GKDYListPlayerController.m
//  GKDYVideo
//
//  Created by QuintGao on 2024/9/9.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKDYListPlayerController.h"
#import "GKDYPlayerManager.h"
#import "GKDYVideoPortraitCell.h"
#import "GKDYVideoLandscapeCell.h"
#import "GKScaleTransition.h"
#import "GKDYCommentView.h"
#import "GKDYUserViewController.h"

@interface GKDYPlayerNavigationController()

@property (nonatomic, strong) GKScaleTransition *transition;

@end

@implementation GKDYPlayerNavigationController

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [super pushViewController:viewController animated:animated];
    
    if ([viewController isKindOfClass:GKDYListPlayerController.class]) {
        self.transition = [[GKScaleTransition alloc] init];
        [self.transition connectToViewController:self];
        self.transition.delegate = (id<GKScaleTransitionDelegate>)viewController;
    }
}

@end


@interface GKDYListPlayerController ()<GKVideoScrollViewDataSource, GKDYVideoScrollViewDelegate, GKDYVideoPortraitCellDelegate, GKScaleTransitionDelegate, GKDYCommentViewDelegate>

@property (nonatomic, strong) GKDYPlayerManager *manager;

@property (nonatomic, strong) GKDYCommentView *commentView;

@property (nonatomic, weak) UIView *containerView;

@end

@implementation GKDYListPlayerController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self initData];
}

- (void)initUI {
    self.gk_navBackgroundColor = UIColor.clearColor;
    self.gk_navLeftBarButtonItem = [UIBarButtonItem gk_itemWithImage:[UIImage gk_imageNamed:@"btn_back_white"] target:self action:@selector(backItemClick:)];
    
    [self.view addSubview:self.scrollView];
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)initData {
    self.view.backgroundColor = UIColor.blackColor;
    self.manager.dataSources = self.videoList;
    self.manager.isAppeared = YES;
    self.scrollView.defaultIndex = self.index;
    [self.scrollView reloadData];
}

- (void)backItemClick:(id)sender {
    [self dismiss];
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - GKScaleTransitionDelegate
@synthesize sourceView;

- (void)transitionPanBegan {
    [self.manager pause];
}

- (void)transitionPanChange {
    
}

- (void)transitionPanEnded:(BOOL)isDismiss {
    if (!isDismiss) {
        [self.manager play];
    }
}

#pragma mark - GKVideoScrollViewDataSource
- (NSInteger)numberOfRowsInScrollView:(GKVideoScrollView *)scrollView {
    return self.manager.dataSources.count;
}

- (GKVideoViewCell *)scrollView:(GKVideoScrollView *)scrollView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *identifier = scrollView == self.scrollView ? @"GKDYVideoPortraitCell" : @"GKDYVideoLandscapeCell";
    GKDYVideoCell *cell = [scrollView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell loadData:self.manager.dataSources[indexPath.row]];
    if ([cell isKindOfClass:GKDYVideoPortraitCell.class]) {
        GKDYVideoPortraitCell *portraitCell = (GKDYVideoPortraitCell *)cell;
        portraitCell.delegate = self;
        portraitCell.manager = self.manager;
    }else {
        GKDYVideoLandscapeCell *landscapeCell = (GKDYVideoLandscapeCell *)cell;
        @weakify(self);
        landscapeCell.backClickBlock = ^{
            @strongify(self);
            [self.manager rotate];
        };
    }
    return cell;
}

#pragma mark - GKDYVideoScrollViewDelegate
- (void)scrollView:(GKVideoScrollView *)scrollView didEndScrollingCell:(UIView *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.manager playVideoWithCell:(GKDYVideoCell *)cell index:indexPath.row];
    
//    [self.vc.currentListVC scrollItemToIndexPath:indexPath];
}

- (void)scrollView:(GKVideoScrollView *)scrollView didEndDisplayingCell:(UIView *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.manager stopPlayWithCell:(GKDYVideoCell *)cell index:indexPath.row];
}

#pragma mark - GKDYVideoCellDelegate
- (void)videoCell:(GKDYVideoCell *)cell didClickIcon:(GKDYVideoModel *)model {
    [self dismiss];
}

- (void)videoCell:(GKDYVideoCell *)cell didClickLike:(GKDYVideoModel *)model {
    model.isLike = !model.isLike;
    [self.scrollView reloadData];
}

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickFullscreen:(GKDYVideoModel *)model {
    [self.manager rotate];
}

- (void)cellDidClickIcon:(GKDYVideoModel *)model {
    GKDYUserViewController *userVC = [[GKDYUserViewController alloc] init];
    userVC.model = model;
    [self.navigationController pushViewController:userVC animated:YES];
}

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickComment:(GKDYVideoModel *)model {
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = UIColor.blackColor;
    containerView.frame = self.view.bounds;
    [self.view addSubview:containerView];
    self.containerView = containerView;
    
    self.commentView.videoModel = model;
    [self.commentView showWithCell:cell containerView:containerView];
}

#pragma mark - GKDYCommentViewDelegate
- (void)commentView:(GKDYCommentView *)commentView showOrHide:(BOOL)show {
    
}

#pragma mark - 懒加载
- (GKDYVideoScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[GKDYVideoScrollView alloc] init];
        _scrollView.dataSource = self;
        _scrollView.delegate = self;
        [_scrollView registerClass:GKDYVideoPortraitCell.class forCellReuseIdentifier:@"GKDYVideoPortraitCell"];
    }
    return _scrollView;
}

- (GKDYPlayerManager *)manager {
    if (!_manager) {
        _manager = [[GKDYPlayerManager alloc] init];
        _manager.scrollView = self.scrollView;
    }
    return _manager;
}

- (GKDYCommentView *)commentView {
    if (!_commentView) {
        _commentView = [[GKDYCommentView alloc] init];
        _commentView.delegate = self;
    }
    return _commentView;
}

- (NSMutableArray *)videoList {
    if (!_videoList) {
        _videoList = [NSMutableArray array];
    }
    return _videoList;
}

- (UIView *)sourceView {
    if ([self.delegate respondsToSelector:@selector(sourceViewWithIndex:)]) {
        NSInteger index = 0;
        if (self.isViewLoaded) {
            index = self.scrollView.currentIndex;
        }else {
            index = self.index;
        }
        return [self.delegate sourceViewWithIndex:index];
    }
    return nil;
}

@end
