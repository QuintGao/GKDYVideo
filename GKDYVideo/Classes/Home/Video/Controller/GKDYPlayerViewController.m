//
//  GKDYPlayerViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYPlayerViewController.h"
#import "GKDYUserViewController.h"
#import "GKSlidePopupView.h"
#import "GKDYCommentView.h"
#import "GKDYCommentControlView.h"
#import "GKBallLoadingView.h"
#import "GKLikeView.h"
#import "GKDYVideoScrollView.h"
#import "GKDYVideoCell.h"
#import "GKDYPlayerManager.h"
#import "GKDYVideoPortraitCell.h"
#import "GKDYVideoLandscapeCell.h"
#import "GKPopupController.h"

@interface GKDYPlayerViewController ()<GKDYPlayerManagerDelegate, GKPopupProtocol, GKDYCommentViewDelegate>

@property (nonatomic, strong) GKDYPlayerManager     *manager;

@property (nonatomic, strong) UIView *containerView;

@property (nonatomic, weak) GKDYVideoPortraitCell *currentCell;
@property (nonatomic, weak) GKDYVideoModel *currentModel;

@property (nonatomic, strong) GKDYCommentView *commentView;

@property (nonatomic, assign) CGFloat playerW;
@property (nonatomic, assign) CGFloat playerH;

@property (nonatomic, assign) BOOL isOpen;
 
@end

@implementation GKDYPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self setupRefresh];
    [self requestData];
}

- (void)dealloc {
    
    NSLog(@"playerVC dealloc");
}

- (void)initUI {
    self.view.backgroundColor = [UIColor blackColor];
    
    [self.view addSubview:self.manager.scrollView];
    
    [self.manager.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupRefresh {
    @weakify(self);
    self.manager.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        self.manager.page++;
        [self requestData:nil];
    }];
}

- (void)requestData {
    GKBallLoadingView *loadingView = [GKBallLoadingView loadingViewInView:self.view];
    [loadingView startLoading];
    
    self.manager.page = 1;
    @weakify(loadingView);
    [self requestData:^{
        @strongify(loadingView);
        [loadingView stopLoading];
        [loadingView removeFromSuperview];
    }];
}

- (void)refreshData:(void (^)(void))completion {
    self.manager.page = 1;
    [self requestData:completion];
}

- (void)requestData:(nullable void (^)(void))completion {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 好看视频 num=5，每次请求5条
//    NSString *url = [NSString stringWithFormat:@"https://haokan.baidu.com/haokan/ui-web/video/feed?tab=%@&act=pcFeed&pd=pc&num=%d", self.tab, 5];
    NSString *url = [NSString stringWithFormat:@"https://haokan.baidu.com/haokan/ui-web/video/rec?tab=%@&act=pcFeed&pd=pc&num=%d", self.tab, 5];
    
    @weakify(self);
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        if ([responseObject[@"status"] integerValue] == 0) {
            NSArray *videos = responseObject[@"data"][@"response"][@"videos"];
            
            if (self.manager.page == 1) {
                [self.manager.dataSources removeAllObjects];
            }
            
            [videos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                GKDYVideoModel *model = [GKDYVideoModel yy_modelWithDictionary:obj];
                [self.manager.dataSources addObject:model];
            }];
            
            [self.manager.scrollView.mj_footer endRefreshing];
            
            if (self.manager.page >= 10) { // 最多10页
                [self.manager.scrollView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.manager.scrollView reloadData];
        }
        !completion ?: completion();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        @strongify(self);
        [self.manager.scrollView.mj_footer endRefreshing];
        !completion ?: completion();
    }];
}

- (GKDYVideoModel *)model {
    return self.manager.currentCell.model;
}

#pragma mark - JXCategoryListContentViewDelegate
- (UIView *)listView {
    return self.view;
}

- (void)listDidAppear {
    self.manager.isAppeared = YES;
    [self.manager play];
}

- (void)listWillDisappear {
    [self.manager pause];
}

- (void)listDidDisappear {
    self.manager.isAppeared = NO;
}

#pragma mark - GKDYPlayerManagerDelegate
- (void)scrollViewDidPanDistance:(CGFloat)distance isEnd:(BOOL)isEnd {
    if ([self.delegate respondsToSelector:@selector(playerVC:didDragDistance:isEnd:)]) {
        [self.delegate playerVC:self didDragDistance:distance isEnd:isEnd];
    }
}

- (void)cellDidClickIcon:(GKDYVideoModel *)model {
    GKDYUserViewController *userVC = [[GKDYUserViewController alloc] init];
    userVC.model = model;
    [self.navigationController pushViewController:userVC animated:YES];
}

- (void)cellDidClickComment:(GKDYVideoModel *)model cell:(GKDYVideoPortraitCell *)cell {
    self.currentCell = cell;
    self.currentModel = model;
    
    GKDYCommentControlView *controlView = [GKDYCommentControlView new];
    self.manager.player.controlView = controlView;
    
    self.containerView.frame = self.view.bounds;
    [self.view addSubview:self.containerView];
    self.manager.player.containerView = self.containerView;
    
    UIView *playView = self.manager.player.currentPlayerManager.view;
    CGRect frame = playView.frame;
    frame.size.height = frame.size.width * self.manager.videoSize.height / self.manager.videoSize.width;
    frame.origin.y = (self.view.bounds.size.height - frame.size.height) / 2;
    playView.frame = frame;
    self.playerW = frame.size.width;
    self.playerH = frame.size.height;
    
    GKPopupController *controller = [[GKPopupController alloc] init];
    controller.delegate = self;
    [controller show];
}

- (void)cellZoomBegan:(GKDYVideoModel *)model {
    if ([self.delegate respondsToSelector:@selector(playerVC:cellZoomBegan:)]) {
        [self.delegate playerVC:self cellZoomBegan:model];
    }
}

- (void)cellZoomEnded:(GKDYVideoModel *)model isFullscreen:(BOOL)isFullscreen {
    if ([self.delegate respondsToSelector:@selector(playerVC:cellZoomEnded:isFullscreen:)]) {
        [self.delegate playerVC:self cellZoomEnded:model isFullscreen:isFullscreen];
    }
}

#pragma mark - GKPopupProtocol
@synthesize popupController;

- (UIView *)contentView {
    return self.commentView;
}

- (CGFloat)contentHeight {
    if (self.isOpen) {
        return (SCREEN_HEIGHT - GK_SAFEAREA_TOP);
    }
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = width * 9 / 16;
    return (SCREEN_HEIGHT - GK_SAFEAREA_TOP - height);
}

- (UIColor *)backColor {
    return UIColor.clearColor;
}

- (void)contentViewWillShow {
    if ([self.delegate respondsToSelector:@selector(playerVC:commentShowOrHide:)]) {
        [self.delegate playerVC:self commentShowOrHide:YES];
    }
    [self.commentView refreshDataWithModel:self.currentModel];
}

- (void)contentViewDidShow {
    [self.commentView requestDataWithModel:self.currentModel];
}

- (void)contentViewDidDismiss {
    self.manager.player.containerView = self.currentCell.coverImgView;
    self.manager.player.controlView = self.currentCell.portraitView;
    [self.containerView removeFromSuperview];
    self.containerView = nil;
    if ([self.delegate respondsToSelector:@selector(playerVC:commentShowOrHide:)]) {
        [self.delegate playerVC:self commentShowOrHide:NO];
    }
    self.isOpen = NO;
}

- (void)contentViewShowAnimation {
    UIView *playView = self.manager.player.currentPlayerManager.view;
    CGRect frame = playView.frame;
    frame.origin.y = GK_SAFEAREA_TOP;
    frame.size.height = SCREEN_HEIGHT - self.contentHeight - GK_SAFEAREA_TOP;
    frame.size.width = frame.size.height * self.playerW / self.playerH;
    
    if (frame.size.width > self.view.frame.size.width) {
        frame.size.width = self.view.frame.size.width;
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
    frame.size.width = self.view.bounds.size.width;
    frame.size.height = frame.size.width * self.playerH / self.playerW;
    frame.origin.y = (self.view.bounds.size.height - frame.size.height) / 2;
    frame.origin.x = 0;
    playView.frame = frame;
}

- (void)panSlideChangeWithRatio:(CGFloat)ratio {
    CGFloat minH = SCREEN_HEIGHT - self.contentHeight - GK_SAFEAREA_TOP;
    CGFloat minW = minH * self.playerW / self.playerH;
    CGFloat minY = GK_SAFEAREA_TOP;
    CGFloat height = self.view.bounds.size.width * self.playerH / self.playerW;
    CGFloat maxY = (self.view.bounds.size.height - height) / 2;
    
    UIView *playView = self.manager.player.currentPlayerManager.view;
    CGRect frame = playView.frame;
    frame.origin.y = MAX(minY, minY + (maxY - minY) * ratio);
    frame.size.width = MAX(minW, minW + (self.view.bounds.size.width - minW) * ratio);
    frame.size.height = frame.size.width * self.playerH / self.playerW;
    playView.frame = frame;
    
    CGPoint center = playView.center;
    center.x = self.view.bounds.size.width * 0.5;
    playView.center = center;
}

#pragma mark - GKDYCommentViewDelegate
- (void)commentViewDidClickClose:(GKDYCommentView *)commentView {
    [self.popupController dismiss];
}

- (void)commentView:(GKDYCommentView *)commentView didClickUnfold:(BOOL)open {
    self.isOpen = open;
    [self.popupController refreshContentHeight];
}

#pragma mark - 懒加载
- (GKDYPlayerManager *)manager {
    if (!_manager) {
        _manager = [[GKDYPlayerManager alloc] init];
        _manager.delegate = self;
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

- (UIView *)containerView {
    if (!_containerView) {
        _containerView = [[UIView alloc] init];
        _containerView.backgroundColor = UIColor.blackColor;
    }
    return _containerView;
}

@end
