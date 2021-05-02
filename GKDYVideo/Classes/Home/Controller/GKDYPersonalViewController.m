//
//  GKDYPersonalViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/24.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYPersonalViewController.h"
#import "GKNetworking.h"
#import "GKDYPersonalModel.h"
#import <GKPageSmoothView/GKPageSmoothView.h>
#import <JXCategoryView/JXCategoryView.h>
#import "GKDYHeaderView.h"
#import "GKDYListCollectionViewCell.h"
#import "GKDYScaleVideoView.h"
#import "GKDYCommentView.h"
#import "GKSlidePopupView.h"

@interface GKDYPersonalViewController ()<GKPageSmoothViewDataSource, GKPageSmoothViewDelegate, JXCategoryViewDelegate, UIScrollViewDelegate, GKDYVideoViewDelegate>

@property (nonatomic, strong) GKPageSmoothView      *smoothView;

@property (nonatomic, strong) GKDYHeaderView        *headerView;

@property (nonatomic, strong) JXCategoryTitleView   *categoryView;

@property (nonatomic, strong) UILabel               *titleView;

@property (nonatomic, weak) GKDYScaleVideoView      *scaleView;

@end

@implementation GKDYPersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBackgroundColor = GKColorRGB(34, 33, 37);
    self.gk_navTitleView = self.titleView;
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    self.gk_navLineHidden = YES;
    self.gk_navBarAlpha = 0;
    
    [self.view addSubview:self.smoothView];
    [self.smoothView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.categoryView.contentScrollView = self.smoothView.listCollectionView;
    self.headerView.model = self.model;
    [self.smoothView reloadData];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.scaleView) {
        [self.view bringSubviewToFront:self.scaleView];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // 默认点击第一个
    [self categoryView:self.categoryView didSelectedItemAtIndex:0];
    
    [self.scaleView.videoView resume];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    [self.scaleView.videoView pause];
}

- (void)showVideoVCWithVideos:(NSArray *)videos index:(NSInteger)index {
    GKDYScaleVideoView *scaleView = [[GKDYScaleVideoView alloc] initWithVC:self videos:videos index:index];
    scaleView.videoView.delegate = self;
    [scaleView show];
    
    self.scaleView = scaleView;
}

#pragma mark - GKPageSmoothViewDataSource
- (UIView *)headerViewInSmoothView:(GKPageSmoothView *)smoothView {
    return self.headerView;
}

- (UIView *)segmentedViewInSmoothView:(GKPageSmoothView *)smoothView {
    return self.categoryView;
}

- (NSInteger)numberOfListsInSmoothView:(GKPageSmoothView *)smoothView {
    return self.categoryView.titles.count;
}

- (id<GKPageSmoothListViewDelegate>)smoothView:(GKPageSmoothView *)smoothView initListAtIndex:(NSInteger)index {
    GKDYListViewController *listVC = [GKDYListViewController new];
    @weakify(self);
    listVC.itemClickBlock = ^(NSArray * _Nonnull videos, NSInteger index) {
        @strongify(self);
        [self showVideoVCWithVideos:videos index:index];
    };
    
    listVC.refreshBlock = ^{
        [smoothView scrollToOriginalPoint];
    };
    
    [self addChildViewController:listVC];
    return listVC;
}

#pragma mark - GKPageSmoothViewDelegate
- (void)smoothView:(GKPageSmoothView *)smoothView listScrollViewDidScroll:(UIScrollView *)scrollView contentOffset:(CGPoint)contentOffset {
    // 导航栏显隐
    CGFloat offsetY = contentOffset.y;
    // 0-100 0
    // 100 - KDYHeaderHeigh - kNavBarheight 渐变从0-1
    // > KDYHeaderHeigh - kNavBarheight 1
    CGFloat alpha = 0;
    if (offsetY < 60) {
        alpha = 0;
    }else if (offsetY > (kDYHeaderHeight - NAVBAR_HEIGHT - 40)) {
        alpha = 1;
    }else {
        alpha = (offsetY - 60) / (kDYHeaderHeight - NAVBAR_HEIGHT - 60);
    }
    self.gk_navBarAlpha = alpha;
    self.titleView.alpha = alpha;
    
    if (offsetY > smoothView.headerContainerHeight) {
        return;
    }
    [self.headerView scrollViewDidScroll:offsetY];
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    self.currentListVC = (GKDYListViewController *)self.smoothView.listDict[@(index)];
}

#pragma mark - GKDYVideoViewDelegate
- (void)videoView:(GKDYVideoView *)videoView didClickIcon:(GKAWEModel *)videoModel {
    GKDYPersonalViewController *personalVC = [GKDYPersonalViewController new];
    personalVC.model = videoModel;
    [self.navigationController pushViewController:personalVC animated:YES];
}

- (void)videoView:(GKDYVideoView *)videoView didClickComment:(GKAWEModel *)videoModel {
    GKDYCommentView *commentView = [GKDYCommentView new];
    commentView.frame = CGRectMake(0, 0, GK_SCREEN_WIDTH, ADAPTATIONRATIO * 980.0f);
    
    GKSlidePopupView *popupView = [GKSlidePopupView popupViewWithFrame:[UIScreen mainScreen].bounds contentView:commentView];
    [popupView showFrom:[UIApplication sharedApplication].keyWindow completion:^{
        [commentView requestData];
    }];
}

#pragma mark - GKPageTableViewGestureDelegate
- (BOOL)prefersStatusBarHidden {
    [self refreshNavBarFrame];
    return self.gk_statusBarHidden;
}

#pragma mark - 懒加载
- (GKPageSmoothView *)smoothView {
    if (!_smoothView) {
        _smoothView = [[GKPageSmoothView alloc] initWithDataSource:self];
        _smoothView.delegate = self;
        _smoothView.ceilPointHeight = GK_STATUSBAR_NAVBAR_HEIGHT;
        _smoothView.listCollectionView.gk_openGestureHandle = YES;
    }
    return _smoothView;
}

- (GKDYHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[GKDYHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kDYHeaderHeight)];
    }
    return _headerView;
}

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40.0f)];
        _categoryView.backgroundColor = GKColorRGB(34, 33, 37);
        _categoryView.titles = @[@"作品 129", @"动态 129", @"喜欢 591"];
        _categoryView.delegate = self;
        _categoryView.titleColor = [UIColor grayColor];
        _categoryView.titleSelectedColor = [UIColor whiteColor];
        _categoryView.titleFont = [UIFont systemFontOfSize:16.0f];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:16.0f];
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorColor = [UIColor yellowColor];
        lineView.indicatorWidth = 80.0f;
        lineView.indicatorCornerRadius = 0;
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;
        _categoryView.indicators = @[lineView];
        
        // 添加分割线
        UIView *btmLineView = [UIView new];
        btmLineView.frame = CGRectMake(0, 40 - 0.5, SCREEN_WIDTH, 0.5);
        btmLineView.backgroundColor = GKColorGray(200);
        [_categoryView addSubview:btmLineView];
    }
    return _categoryView;
}

- (UILabel *)titleView {
    if (!_titleView) {
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
        _titleView.font = [UIFont systemFontOfSize:18.0f];
        _titleView.textColor = [UIColor whiteColor];
        _titleView.alpha = 0;
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.text = self.model.author.nickname;
    }
    return _titleView;
}

@end
