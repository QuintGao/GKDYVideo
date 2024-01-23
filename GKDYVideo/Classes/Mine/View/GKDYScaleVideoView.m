//
//  GKDYScaleVideoView.m
//  GKDYVideo
//
//  Created by gaokun on 2019/7/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKDYScaleVideoView.h"
#import "GKDYVideoListCell.h"
#import "GKDYVideoPortraitCell.h"
#import "GKDYVideoLandscapeCell.h"
#import "GKDYCommentView.h"
#import "GKDYCommentControlView.h"
#import "GKPopupController.h"

#define kBottomHeight (GK_SAFEAREA_BTM + 50)

@interface GKDYScaleVideoView()<GKVideoScrollViewDataSource, GKDYVideoScrollViewDelegate, GKDYVideoPortraitCellDelegate, UIGestureRecognizerDelegate, GKPopupProtocol>

@property (nonatomic, assign) BOOL      interacting;

@property (nonatomic, strong) UIView    *snapshotView;

@property (nonatomic, assign) CGPoint   videoCenter;

// 顶部
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIButton *backBtn;
@property (nonatomic, strong) UIView *searchView;
@property (nonatomic, strong) UILabel *searchLabel;

// 底部
@property (nonatomic, strong) UIView    *bottomView;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, weak) GKDYVideoPortraitCell *currentCell;
@property (nonatomic, weak) GKDYVideoModel *currentModel;

@property (nonatomic, strong) GKDYCommentView *commentView;

@property (nonatomic, assign) CGFloat playerW;
@property (nonatomic, assign) CGFloat playerH;

@end

@implementation GKDYScaleVideoView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
        [self setupRefresh];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.scrollView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height - kBottomHeight);
}

- (void)initUI {
    self.backgroundColor = UIColor.blackColor;
    [self addSubview:self.scrollView];
    [self addSubview:self.topView];
    [self.topView addSubview:self.backBtn];
    [self.topView addSubview:self.searchView];
    [self.topView addSubview:self.searchLabel];
    [self addSubview:self.bottomView];
    
    self.scrollView.frame = CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - kBottomHeight);
    
    [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.top.equalTo(self).offset(GK_SAFEAREA_TOP);
        make.height.mas_equalTo(44);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.topView).offset(2);
        make.centerY.equalTo(self.topView);
        make.width.height.mas_equalTo(44);
    }];
    
    [self.searchView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.backBtn.mas_right).offset(5);
        make.right.equalTo(self.topView).offset(-16);
        make.centerY.equalTo(self.topView);
        make.height.mas_equalTo(30);
    }];
    
    [self.searchLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.searchView.mas_right).offset(-8);
        make.centerY.equalTo(self.topView);
    }];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(kBottomHeight);
    }];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] init];
    [panGesture addTarget:self action:@selector(handlePanGesture:)];
    [self addGestureRecognizer:panGesture];
}

- (void)setupRefresh {
    @weakify(self);
    self.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        !self.requestBlock ?: self.requestBlock();
    }];
}

- (void)backClick:(id)sender {
    [self dismiss];
}

- (void)reloadData {
    [self.scrollView.mj_footer endRefreshing];
    [self.scrollView reloadData];
}

- (void)show {
    self.manager.dataSources = self.videoList;
    self.manager.isAppeared = YES;
    self.scrollView.defaultIndex = self.index;
    [self.scrollView reloadData];
    
    // 禁用手势
    self.vc.gk_interactivePopDisabled = YES;
    
    // 添加视图
    [self.vc.view addSubview:self];
    
    // 获取当前显示的列表控制器
    GKDYVideoListViewController *listVC = self.vc.currentListVC;
    
    // 获取当前点击的cell
    GKDYVideoListCell *cell = (GKDYVideoListCell *)[listVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:listVC.selectedIndex inSection:0]];
    
    // 获取cell快照
    self.snapshotView = [cell snapshotViewAfterScreenUpdates:NO];
    self.snapshotView.frame = self.bounds;
    [self addSubview:self.snapshotView];
    
    CGRect originalFrame = [listVC.collectionView convertRect:cell.frame toView:self.vc.view];
    CGRect finalFrame = self.vc.view.frame;
    
    self.frame = finalFrame;
    
    self.center = CGPointMake(originalFrame.origin.x + originalFrame.size.width * 0.5, originalFrame.origin.y + originalFrame.size.height * 0.5);
    self.transform = CGAffineTransformMakeScale(originalFrame.size.width / finalFrame.size.width, originalFrame.size.height / finalFrame.size.height);
    
    // 显示动画
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:1 options:UIViewAnimationOptionLayoutSubviews animations:^{
        self.center = CGPointMake(finalFrame.origin.x + finalFrame.size.width * 0.5, finalFrame.origin.y + finalFrame.size.height * 0.5);
        self.transform = CGAffineTransformIdentity;
        self.snapshotView.alpha = 0;
    } completion:^(BOOL finished) {
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
    }];
}

- (void)dismiss {
    // 获取当前显示的控制器
    GKDYVideoListViewController *listVC = self.vc.currentListVC;
    
    // 获取cell
    UICollectionViewCell *cell = [listVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.scrollView.currentIndex inSection:0]];
    
    CGRect originalFrame = self.vc.view.frame;
    CGRect finalFrame = [listVC.collectionView convertRect:cell.frame toView:self.vc.view];
    
    // 获取cell快照
    if (!self.snapshotView) {
        self.snapshotView = [cell snapshotViewAfterScreenUpdates:NO];
        self.snapshotView.alpha = 0;
        self.snapshotView.frame = self.bounds;
        [self addSubview:self.snapshotView];
        cell.hidden = YES;
    }
    
    // 隐藏动画
    [UIView animateWithDuration:0.25 animations:^{
        self.center = CGPointMake(finalFrame.origin.x + finalFrame.size.width * 0.5, finalFrame.origin.y + finalFrame.size.height * 0.5);
        self.transform = CGAffineTransformMakeScale(finalFrame.size.width / originalFrame.size.width, finalFrame.size.height / originalFrame.size.height);
        self.snapshotView.alpha = 1;
    } completion:^(BOOL finished) {
        cell.hidden = NO;
        [self.snapshotView removeFromSuperview];
        self.snapshotView = nil;
        [self removeFromSuperview];
        self.vc.gk_interactivePopDisabled = NO;
    }];
}

#pragma mark - Gesture
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:panGesture.view.superview];
    if (!self.interacting && (translation.x < 0 || translation.y < 0 || translation.x < translation.y)) return;
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan:
            [self handlePanBegan:panGesture];
            break;
        case UIGestureRecognizerStateChanged:
            [self handlePanChange:panGesture];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self handlePanEnded:panGesture];
            break;
            
        default:
            break;
    }
}

- (void)handlePanBegan:(UIPanGestureRecognizer *)gesture {
    // 修复当从右侧向左侧滑动时的bug，避免开始的时候从右向左滑动
    CGPoint vel = [gesture velocityInView:gesture.view];
    if (!self.interacting && vel.x < 0) {
        self.interacting = NO;
        return;
    }
    self.videoCenter = self.vc.view.center;
    self.interacting = YES;
    [self.manager pause];
    // 获取当前显示的列表控制器
    GKDYVideoListViewController *listVC = self.vc.currentListVC;
    
    // 获取当前点击的cell
    GKDYVideoListCell *cell = (GKDYVideoListCell *)[listVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.scrollView.currentIndex inSection:0]];
    self.snapshotView = [cell snapshotViewAfterScreenUpdates:NO];
    self.snapshotView.alpha = 0;
    self.snapshotView.frame = self.bounds;
    [self addSubview:self.snapshotView];
    cell.hidden = YES;
}

- (void)handlePanChange:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:gesture.view.superview];
    
    CGFloat progress = [self panGestureProgress:gesture];
    CGFloat ratio = 1.0f - progress * 0.5;
    
    self.center = CGPointMake(self.videoCenter.x + translation.x * ratio, self.videoCenter.y + translation.y * ratio);
    self.transform = CGAffineTransformMakeScale(ratio, ratio);
}

- (void)handlePanEnded:(UIPanGestureRecognizer *)gesture {
    CGFloat progress = [self panGestureProgress:gesture];
    if (progress < 0.2) { // 恢复
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.center = self.videoCenter;
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.vc.gk_interactivePopDisabled = YES;
            self.interacting = NO;
            [self.manager play];
            [self.snapshotView removeFromSuperview];
            self.snapshotView = nil;
        }];
    }else { // 消失
        [self dismiss];
    }
}

- (CGFloat)panGestureProgress:(UIPanGestureRecognizer *)panGesture {
    UIView *superview = panGesture.view.superview;
    CGPoint translation = [panGesture translationInView:superview];
    CGFloat progress = translation.x / superview.frame.size.width;
    progress = fminf(fmaxf(progress, 0.0), 1.0);
    return progress;
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
    
    [self.vc.currentListVC scrollItemToIndexPath:indexPath];
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

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickComment:(GKDYVideoModel *)model {
    self.currentCell = cell;
    self.currentModel = model;
    
    GKDYCommentControlView *controlView = [GKDYCommentControlView new];
    self.manager.player.controlView = controlView;
    
    self.containerView.frame = self.bounds;
    [self addSubview:self.containerView];
    self.manager.player.containerView = self.containerView;
    
    UIView *playView = self.manager.player.currentPlayerManager.view;
    CGRect frame = playView.frame;
    frame.size.height = frame.size.width * self.manager.videoSize.height / self.manager.videoSize.width;
    frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
    playView.frame = frame;
    self.playerW = frame.size.width;
    self.playerH = frame.size.height;
    
    GKPopupController *controller = [[GKPopupController alloc] init];
    controller.delegate = self;
    [controller show];
}

#pragma mark - GKPopupProtocol
@synthesize popupController;

- (UIView *)contentView {
    return self.commentView;
}

- (CGFloat)contentHeight {
    CGFloat width = self.bounds.size.width;
    CGFloat height = width * 9 / 16;
    return (SCREEN_HEIGHT - GK_SAFEAREA_TOP - height);
}

- (UIColor *)backColor {
    return UIColor.clearColor;
}

- (void)contentViewWillShow {
    
}

- (void)contentViewDidShow {
    [self.commentView requestDataWithModel:self.currentModel];
}

- (void)contentViewDidDismiss {
    self.manager.player.containerView = self.currentCell.coverImgView;
    self.manager.player.controlView = self.currentCell.portraitView;
    [self.containerView removeFromSuperview];
    self.containerView = nil;
}

- (void)contentViewShowAnimation {
    UIView *playView = self.manager.player.currentPlayerManager.view;
    CGRect frame = playView.frame;
    frame.origin.y = GK_SAFEAREA_TOP;
    frame.size.height = SCREEN_HEIGHT - self.contentHeight - GK_SAFEAREA_TOP;
    frame.size.width = frame.size.height * self.playerW / self.playerH;
    if (frame.size.width > self.bounds.size.width) {
        frame.size.width = self.bounds.size.width;
        frame.size.height = frame.size.width * self.playerH / self.playerW;
    }
    playView.frame = frame;
    
    CGPoint center = playView.center;
    center.x = self.containerView.frame.size.width / 2;
    playView.center = center;
}

- (void)contentViewDismissAnimation {
    UIView *playView = self.manager.player.currentPlayerManager.view;
    CGRect frame = playView.frame;
    frame.size.width = self.bounds.size.width;
    frame.size.height = frame.size.width * self.playerH / self.playerW;
    frame.origin.y = (self.bounds.size.height - frame.size.height) / 2;
    frame.origin.x = 0;
    playView.frame = frame;
}

- (void)panSlideChangeWithRatio:(CGFloat)ratio {
    CGFloat minH = SCREEN_HEIGHT - self.contentHeight - GK_SAFEAREA_TOP;
    CGFloat minW = minH * self.playerW / self.playerH;
    CGFloat minY = GK_SAFEAREA_TOP;
    CGFloat height = self.bounds.size.width * self.playerH / self.playerW;
    CGFloat maxY = (self.bounds.size.height - height) / 2;
    
    UIView *playView = self.manager.player.currentPlayerManager.view;
    CGRect frame = playView.frame;
    frame.origin.y = MAX(minY, minY + (maxY - minY) * ratio);
    frame.size.width = MAX(minW, minW + (self.bounds.size.width - minW) * ratio);
    frame.size.height = frame.size.width * self.playerH / self.playerW;
    playView.frame = frame;
    
    CGPoint center = playView.center;
    center.x = self.bounds.size.width * 0.5;
    playView.center = center;
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

- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
        _bottomView.backgroundColor = UIColor.blackColor;
    }
    return _bottomView;
}

- (NSMutableArray *)videoList {
    if (!_videoList) {
        _videoList = [NSMutableArray array];
    }
    return _videoList;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [[UIView alloc] init];
    }
    return _topView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"icTitlebarBackWhite_Normal"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UIView *)searchView {
    if (!_searchView) {
        _searchView = [[UIView alloc] init];
        _searchView.backgroundColor = [UIColor.whiteColor colorWithAlphaComponent:0.4];
        _searchView.layer.cornerRadius = 5;
        _searchView.layer.masksToBounds = YES;
    }
    return _searchView;
}

- (UILabel *)searchLabel {
    if (!_searchLabel) {
        _searchLabel = [[UILabel alloc] init];
        _searchLabel.font = [UIFont systemFontOfSize:15];
        _searchLabel.textColor = UIColor.whiteColor;
        _searchLabel.text = @"搜索";
    }
    return _searchLabel;
}

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = UIColor.blackColor;
    }
    return _containerView;
}

- (GKDYCommentView *)commentView {
    if (!_commentView) {
        _commentView = [[GKDYCommentView alloc] init];
    }
    return _commentView;
}

@end
