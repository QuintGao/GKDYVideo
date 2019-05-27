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
#import <GKPageScrollView/GKPageScrollView.h>
#import <JXCategoryView/JXCategoryView.h>
#import "GKDYHeaderView.h"
#import "GKDYListViewController.h"

@interface GKDYPersonalViewController ()<GKPageScrollViewDelegate, JXCategoryViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) GKPageScrollView      *pageScrollView;

@property (nonatomic, strong) GKDYHeaderView        *headerView;

@property (nonatomic, strong) UIView                *pageView;
@property (nonatomic, strong) JXCategoryTitleView   *categoryView;
@property (nonatomic, strong) UIScrollView          *scrollView;

@property (nonatomic, strong) NSArray               *titles;

@property (nonatomic, strong) UILabel               *titleView;

@end

@implementation GKDYPersonalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBarAlpha = 0;
    self.gk_navBackgroundColor = GKColorRGB(34, 33, 37);
    
    self.gk_navTitleView = self.titleView;
    
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    
    self.gk_navLineHidden = YES;
    
    [self.view addSubview:self.pageScrollView];
    [self.pageScrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.headerView.model = self.model;
    
    [self.pageScrollView reloadData];
    
    // 默认点击第一个
    [self categoryView:self.categoryView didSelectedItemAtIndex:0];
}

#pragma mark - GKPageScrollViewDelegate
- (BOOL)shouldLazyLoadListInPageScrollView:(GKPageScrollView *)pageScrollView {
    return YES;
}

- (UIView *)headerViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.headerView;
}

- (UIView *)segmentedViewInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.categoryView;
}

- (NSInteger)numberOfListsInPageScrollView:(GKPageScrollView *)pageScrollView {
    return self.titles.count;
}

- (id<GKPageListViewDelegate>)pageScrollView:(GKPageScrollView *)pageScrollView initListAtIndex:(NSInteger)index {
    GKDYListViewController *listVC = [GKDYListViewController new];
    return listVC;
}

- (void)mainTableViewDidScroll:(UIScrollView *)scrollView isMainCanScroll:(BOOL)isMainCanScroll {
    // 导航栏显隐
    CGFloat offsetY = scrollView.contentOffset.y;
    // 0-200 0
    // 200 - KDYHeaderHeigh - kNavBarheight 渐变从0-1
    // > KDYHeaderHeigh - kNavBarheight 1
    CGFloat alpha = 0;
    if (offsetY < 200) {
        alpha = 0;
    }else if (offsetY > (kDYHeaderHeight - NAVBAR_HEIGHT)) {
        alpha = 1;
    }else {
        alpha = (offsetY - 200) / (kDYHeaderHeight - NAVBAR_HEIGHT - 200);
    }
    self.gk_navBarAlpha = alpha;
    self.titleView.alpha = alpha;
    
    [self.headerView scrollViewDidScroll:offsetY];
}

#pragma mark - JXCategoryViewDelegate
- (void)categoryView:(JXCategoryBaseView *)categoryView didSelectedItemAtIndex:(NSInteger)index {
    
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewWillBeginScroll];
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self.pageScrollView horizonScrollViewDidEndedScroll];
}


#pragma mark - 懒加载
- (GKPageScrollView *)pageScrollView {
    if (!_pageScrollView) {
        _pageScrollView = [[GKPageScrollView alloc] initWithDelegate:self];
    }
    return _pageScrollView;
}

- (GKDYHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[GKDYHeaderView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kDYHeaderHeight)];
    }
    return _headerView;
}

- (UIView *)pageView {
    if (!_pageView) {
        _pageView = [UIView new];
        _pageView.backgroundColor = [UIColor clearColor];
        
        [_pageView addSubview:self.categoryView];
        [_pageView addSubview:self.scrollView];
    }
    return _pageView;
}

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 40.0f)];
        _categoryView.backgroundColor = GKColorRGB(34, 33, 37);
        _categoryView.titles = self.titles;
        _categoryView.delegate = self;
        _categoryView.titleColor = [UIColor grayColor];
        _categoryView.titleSelectedColor = [UIColor whiteColor];
        _categoryView.titleFont = [UIFont systemFontOfSize:16.0f];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:16.0f];
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorLineViewColor = [UIColor yellowColor];
        lineView.indicatorLineWidth = 80.0f;
        lineView.indicatorLineViewCornerRadius = 0;
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;
        _categoryView.indicators = @[lineView];
        
        _categoryView.contentScrollView = self.pageScrollView.listContainerView.collectionView;
        
        // 添加分割线
        UIView *btmLineView = [UIView new];
        btmLineView.frame = CGRectMake(0, 40 - 0.5, SCREEN_WIDTH, 0.5);
        btmLineView.backgroundColor = GKColorGray(200);
        [_categoryView addSubview:btmLineView];
    }
    return _categoryView;
}

- (NSArray *)titles {
    if (!_titles) {
        _titles = @[@"作品 129", @"动态 129", @"喜欢 591"];
    }
    return _titles;
}

- (UILabel *)titleView {
    if (!_titleView) {
        _titleView = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 160, 44)];
        _titleView.font = [UIFont systemFontOfSize:18.0f];
        _titleView.textColor = [UIColor whiteColor];
        _titleView.alpha = 0;
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.text = self.model.author.name_show;
    }
    return _titleView;
}

@end
