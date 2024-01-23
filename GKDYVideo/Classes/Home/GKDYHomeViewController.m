//
//  GKDYHomeViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYHomeViewController.h"
#import "GKDYSearchViewController.h"
#import "GKDYPlayerViewController.h"
#import "GKDYUserViewController.h"
#import "GKDYMainViewController.h"
#import "GKDYScrollView.h"
#import "GKDYTitleView.h"
#import "GKBallLoadingView.h"

@interface GKDYHomeViewController()<UIScrollViewDelegate, GKViewControllerPushDelegate, JXCategoryViewDelegate, JXCategoryListContainerViewDelegate, GKDYPlayerViewControllerDelegate>

@property (nonatomic, strong) GKDYTitleView *titleView;

@property (nonatomic, strong) JXCategoryListContainerView *containerView;

@property (nonatomic, strong) NSArray *titles;

@end

@implementation GKDYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self requestData];
}

- (void)changeToSearch:(NSNotification *)notify {
//    [self.mainScrolView setContentOffset:CGPointZero animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // 设置左滑push代理
    if (self.titleView.categoryView.selectedIndex == self.titles.count - 1) {
        self.gk_pushDelegate = self;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 取消push代理
    self.gk_pushDelegate = nil;
}

- (void)initUI {
    self.gk_navigationBar.hidden    = YES;
    
    [self.view addSubview:self.containerView];
    [self.view addSubview:self.titleView];
    
    [self.containerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self.view);
        make.top.equalTo(self.view).offset(GK_SAFEAREA_TOP);
        make.height.mas_equalTo(44);
    }];
}

- (void)requestData {
    self.titles = @[@{@"title": @"影视", @"tab": @"yingshi_new"},
                    @{@"title": @"音乐", @"tab": @"yinyue_new"},
                    @{@"title": @"游戏", @"tab": @"youxi_new"},
                    @{@"title": @"搞笑", @"tab": @"gaoxiao_new"},
                    @{@"title": @"推荐", @"tab": @"recommend"}];
    
    NSMutableArray *titles = [NSMutableArray array];
    [self.titles enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [titles addObject:obj[@"title"]];
    }];
    self.titleView.categoryView.titles = titles;
    self.titleView.categoryView.defaultSelectedIndex = titles.count - 1;
    [self.titleView.categoryView reloadData];
}

- (void)requestCurrentList {
    @weakify(self);
    [self.playerVC refreshData:^{
        @strongify(self);
        [self.titleView loadingEnd];
    }];
}

- (GKDYPlayerViewController *)playerVC {
    return (GKDYPlayerViewController *)self.containerView.validListDict[@(self.titleView.categoryView.selectedIndex)];
}

#pragma mark - GKViewControllerPushDelegate
- (void)pushToNextViewController {
    GKDYUserViewController *userVC = [GKDYUserViewController new];
    userVC.model = self.playerVC.model;
    [self.navigationController pushViewController:userVC animated:YES];
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    if (index == self.titles.count - 1) {
        self.gk_pushDelegate = self;
    }else {
        self.gk_pushDelegate = nil;
    }
}

#pragma mark - JXCategoryListContainerViewDelegate
- (NSInteger)numberOfListsInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return self.titles.count;
}

- (id<JXCategoryListContentViewDelegate>)listContainerView:(JXCategoryListContainerView *)listContainerView initListForIndex:(NSInteger)index {
    GKDYPlayerViewController *playerVC = [[GKDYPlayerViewController alloc] init];
    playerVC.tab = self.titles[index][@"tab"];
    playerVC.delegate = self;
    return playerVC;
}

- (Class)scrollViewClassInlistContainerView:(JXCategoryListContainerView *)listContainerView {
    return GKDYScrollView.class;
}

#pragma mark - GKDYPlayerViewControllerDelegate
- (void)playerVC:(GKDYPlayerViewController *)playerVC didDragDistance:(CGFloat)distance isEnd:(BOOL)isEnd {
    [self.titleView changeAlphaWithDistance:distance isEnd:isEnd];
}

- (void)playerVC:(GKDYPlayerViewController *)playerVC cellZoomBegan:(GKDYVideoModel *)model {
    self.titleView.hidden = YES;
    self.tabBarController.tabBar.hidden = YES;
}

- (void)playerVC:(GKDYPlayerViewController *)playerVC cellZoomEnded:(GKDYVideoModel *)model isFullscreen:(BOOL)isFullscreen {
    self.titleView.hidden = isFullscreen;
    self.tabBarController.tabBar.hidden = isFullscreen;
}

- (void)playerVC:(GKDYPlayerViewController *)playerVC commentShowOrHide:(BOOL)show {
    self.titleView.hidden = show;
}

- (void)searchClick:(id)sender {
    
}

#pragma mark - 懒加载
- (GKDYTitleView *)titleView {
    if (!_titleView) {
        _titleView = [[GKDYTitleView alloc] init];
        _titleView.categoryView.delegate = self;
        _titleView.categoryView.listContainer = self.containerView;
        
        @weakify(self);
        _titleView.loadingBlock = ^{
            @strongify(self);
            [self requestCurrentList];
        };
    }
    return _titleView;
}

- (JXCategoryListContainerView *)containerView {
    if (!_containerView) {
        _containerView = [[JXCategoryListContainerView alloc] initWithType:JXCategoryListContainerType_ScrollView delegate:self];
    }
    return _containerView;
}

@end
