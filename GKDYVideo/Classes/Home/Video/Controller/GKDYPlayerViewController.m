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
#import "GKRedPreloadManager.h"

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
        [self requestMore];
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

- (void)requestMore {
    self.manager.page++;
    [self requestData:nil];
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
            
            NSMutableArray *videoUrls = [NSMutableArray new];
            [videos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                GKDYVideoModel *model = [GKDYVideoModel yy_modelWithDictionary:obj];
                [self.manager.dataSources addObject:model];
                
                [videoUrls addObject:model.play_url];
            }];
            
            // 预加载
            [self preloadVideoUrls:videoUrls];
            
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

- (void)preloadVideoUrls:(NSArray *)videoUrls {
    [videoUrls enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [GKRedPreloadManager preloadVideoURL:[NSURL URLWithString:obj]];
    }];
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
- (void)scrollViewShouldLoadMore {
    [self requestMore];
}

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
    
    self.commentView.player = self.manager.player;
    self.commentView.videoModel = model;
    
    self.containerView.frame = self.view.bounds;
    [self.view addSubview:self.containerView];
    self.commentView.containerView = self.containerView;
    
    [self.commentView show];
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

#pragma mark - GKDYCommentViewDelegate
- (void)commentView:(GKDYCommentView *)commentView showOrHide:(BOOL)show {
    if (!show) {
        self.manager.player.containerView = self.currentCell.coverImgView;
        self.manager.player.controlView = self.currentCell.portraitView;
        [self.commentView.containerView removeFromSuperview];
    }
    
    if ([self.delegate respondsToSelector:@selector(playerVC:commentShowOrHide:)]) {
        [self.delegate playerVC:self commentShowOrHide:show];
    }
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
