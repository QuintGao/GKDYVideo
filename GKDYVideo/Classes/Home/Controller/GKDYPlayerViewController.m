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
#import "GKBallLoadingView.h"
#import "GKLikeView.h"
#import "GKDYVideoScrollView.h"
#import "GKDYVideoCell.h"
#import "GKDYPlayerManager.h"

@interface GKDYPlayerViewController ()<GKVideoScrollViewDataSource, GKDYVideoScrollViewDelegate, GKViewControllerPushDelegate, GKDYVideoCellDelegate>

@property (nonatomic, strong) GKDYVideoScrollView   *scrollView;

@property (nonatomic, strong) GKDYPlayerManager     *manager;

@end

@implementation GKDYPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self setupRefresh];
    [self requestData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
}

- (void)dealloc {
    
    NSLog(@"playerVC dealloc");
}

- (void)initUI {
    self.view.backgroundColor = [UIColor blackColor];

    [self.view addSubview:self.scrollView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}

- (void)setupRefresh {
    @weakify(self);
    self.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        self.manager.page++;
        [self.manager requestDataWithTab:self.tab completion:nil];
    }];
}

- (void)requestData {
    GKBallLoadingView *loadingView = [GKBallLoadingView loadingViewInView:self.view];
    [loadingView startLoading];
    
    self.manager.page = 1;
    @weakify(loadingView);
    [self.manager requestDataWithTab:self.tab completion:^{
        @strongify(loadingView);
        [loadingView stopLoading];
        [loadingView removeFromSuperview];
    }];
}

- (void)requestData:(void (^)(void))completion {
    self.manager.page = 1;
    [self.manager requestDataWithTab:self.tab completion:^{
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

#pragma mark - GKDYVideoScrollViewDataSource
- (NSInteger)numberOfRowsInScrollView:(GKVideoScrollView *)scrollView {
    return self.manager.dataSources.count;
}

- (UIView *)scrollView:(GKVideoScrollView *)scrollView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKDYVideoCell *cell = [scrollView dequeueReusableCellWithIdentifier:@"GKDYVideoCell" forIndexPath:indexPath];
    cell.model = self.manager.dataSources[indexPath.row];
    cell.delegate = self;
    cell.manager = self.manager;
    return cell;
}

#pragma mark - GKDYVideoScrollViewDelegate
- (void)scrollView:(GKVideoScrollView *)scrollView didEndScrollingCell:(UIView *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.manager playVideoWithCell:(GKDYVideoCell *)cell index:indexPath.row];
}

- (void)scrollView:(GKVideoScrollView *)scrollView didEndDisplayingCell:(UIView *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.manager stopPlayWithCell:(GKDYVideoCell *)cell index:indexPath.row];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.scrollView.currentIndex == 0 && scrollView.contentOffset.y < 0) {
        self.scrollView.contentOffset = CGPointZero;
    }
}

- (void)scrollView:(GKDYVideoScrollView *)scrollView didPanWithDistance:(CGFloat)distance isEnd:(BOOL)isEnd {
    if ([self.delegate respondsToSelector:@selector(playerVC:didDragDistance:isEnd:)]) {
        [self.delegate playerVC:self didDragDistance:distance isEnd:isEnd];
    }
}

#pragma mark - GKDYVideoCellDelegate
- (void)videoCell:(GKDYVideoCell *)cell didClickIcon:(GKDYVideoModel *)model {
    GKDYUserViewController *userVC = [[GKDYUserViewController alloc] init];
    userVC.model = model;
    [self.navigationController pushViewController:userVC animated:YES];
}

- (void)videoCell:(GKDYVideoCell *)cell didClickLike:(GKDYVideoModel *)model {
    model.isLike = !model.isLike;
    [self.scrollView reloadData];
}

- (void)videoCell:(GKDYVideoCell *)cell didClickComment:(GKDYVideoModel *)model {
    
    self.tabBarController.tabBar.hidden = YES;
    GKDYCommentView *commentView = [GKDYCommentView new];
    commentView.backgroundColor = UIColor.whiteColor;
    commentView.frame = CGRectMake(0, 0, SCREEN_WIDTH, ADAPTATIONRATIO * 980.0f);

    GKSlidePopupView *popupView = [GKSlidePopupView popupViewWithFrame:UIScreen.mainScreen.bounds contentView:commentView];
    [popupView showFrom:UIApplication.sharedApplication.keyWindow completion:^{
        [commentView requestData];
    }];
}

- (void)videoCell:(GKDYVideoCell *)cell didClickShare:(GKDYVideoModel *)model {
    
}

- (void)videoCell:(GKDYVideoCell *)cell didClickDanmu:(GKDYVideoModel *)model {
    
}

#pragma mark - 懒加载
- (GKDYVideoScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[GKDYVideoScrollView alloc] init];
        _scrollView.dataSource = self;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = UIColor.blackColor;
        [_scrollView registerClass:GKDYVideoCell.class forCellReuseIdentifier:@"GKDYVideoCell"];
        [_scrollView addPanGesture];
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

@end
