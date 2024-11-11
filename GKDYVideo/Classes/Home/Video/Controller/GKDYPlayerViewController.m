//
//  GKDYPlayerViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYPlayerViewController.h"
#import "GKDYUserViewController.h"
#import "GKDYCommentView.h"
#import "GKDYCommentControlView.h"
#import "GKBallLoadingView.h"
#import "GKLikeView.h"
#import "GKDYVideoScrollView.h"
#import "GKDYVideoCell.h"
#import "GKDYPlayerManager.h"
#import "GKDYVideoPortraitCell.h"
#import "GKDYVideoLandscapeCell.h"

@interface GKDYPlayerViewController ()<GKDYPlayerManagerDelegate, GKDYCommentViewDelegate>

@property (nonatomic, strong) GKDYPlayerManager *manager;

@property (nonatomic, strong) GKDYCommentView *commentView;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, weak) GKBallLoadingView *loadingView;
 
@end

@implementation GKDYPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self setupRefresh];
    [self requestData];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(networkChange) name:@"NetworkChange" object:nil];
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
    self.loadingView = loadingView;
    
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

#pragma mark - notification
- (void)networkChange {
    if (self.manager.dataSources.count == 0 && !self.loadingView) {
        [self requestData];
    }
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
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = UIColor.blackColor;
    containerView.frame = self.view.bounds;
    [self.view addSubview:containerView];
    self.containerView = containerView;
    
    self.commentView.videoModel = model;
    [self.commentView showWithCell:cell containerView:self.containerView];
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

@end
