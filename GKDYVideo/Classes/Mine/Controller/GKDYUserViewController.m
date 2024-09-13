//
//  GKDYUserViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYUserViewController.h"
#import <GKPageSmoothView/GKPageSmoothView.h>
#import <JXCategoryView/JXCategoryView.h>
#import "GKDYUserHeaderView.h"
#import "GKDYVideoListViewController.h"
#import "GKDYScaleVideoView.h"
#import "GKDYListPlayerController.h"

@interface GKDYUserViewController ()<GKPageSmoothViewDataSource, GKPageSmoothViewDelegate, GKDYListPlayerControllerDelegate>

@property (nonatomic, strong) UILabel *titleView;

@property (nonatomic, strong) GKPageSmoothView *smoothView;

@property (nonatomic, strong) GKDYUserHeaderView *headerView;

@property (nonatomic, strong) JXCategoryTitleView *categoryView;

@property (nonatomic, weak) GKDYScaleVideoView *videoView;

@end

@implementation GKDYUserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self requestData];
}

- (void)initUI {
    self.gk_navBackgroundColor = GKColorRGB(34, 33, 37);
    self.gk_navTitleView = self.titleView;
    self.gk_statusBarStyle = UIStatusBarStyleLightContent;
    self.gk_navLineHidden = YES;
    self.gk_navBarAlpha = 0;
    self.gk_navRightBarButtonItem = [UIBarButtonItem gk_itemWithTitle:@"测试" target:self action:@selector(testClick)];
    
    [self.view addSubview:self.smoothView];
    [self.smoothView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.categoryView.contentScrollView = self.smoothView.listCollectionView;
}

- (void)testClick {
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:9 inSection:0];
    [self.currentListVC scrollItemToIndexPath:indexPath];
}

- (void)requestData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *url = [NSString stringWithFormat:@"https://haokan.baidu.com/haokan/ui-web/author/info?vid=%@", self.model.video_id];
    
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"status"] integerValue] == 0) {
            GKDYUserModel *model = [GKDYUserModel yy_modelWithDictionary:responseObject[@"data"][@"response"]];
            model.author_icon = self.model.author_avatar;
            self.headerView.model = model;
            [self.smoothView reloadData];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"%@", error);
    }];
}

- (GKDYVideoListViewController *)currentListVC {
    return (GKDYVideoListViewController *)self.smoothView.listDict[@(self.categoryView.selectedIndex)];
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
    GKDYVideoListViewController *listVC = [[GKDYVideoListViewController alloc] init];
    listVC.uid = self.model.third_id;
    @weakify(self);
    [listVC setCellClickBlock:^(NSArray * _Nonnull list, NSInteger index) {
        @strongify(self);
        [self showVideoViewWithList:list index:index];
    }];
    return listVC;
}

#pragma mark - GKPageSmoothViewDelegate
- (void)smoothView:(GKPageSmoothView *)smoothView listScrollViewDidScroll:(UIScrollView *)scrollView contentOffset:(CGPoint)contentOffset {
    // 导航栏渐变
    CGFloat offsetY = contentOffset.y;
    
    CGFloat alpha = 0;
    if (offsetY < 60) {
        alpha = 0;
    }else if (offsetY > (kDYUserHeaderHeight - GK_STATUSBAR_NAVBAR_HEIGHT - 60)) {
        alpha = 1;
    }else {
        alpha = (offsetY - 60) / (kDYUserHeaderHeight - GK_STATUSBAR_NAVBAR_HEIGHT - 60);
    }
    self.gk_navBarAlpha = alpha;
    self.titleView.alpha = alpha;
    if (offsetY > smoothView.headerContainerHeight) return;
    [self.headerView scrollViewDidScroll:offsetY];
}

#pragma mark - Private
- (void)showVideoViewWithList:(NSArray *)list index:(NSInteger)index {
    GKDYListPlayerController *listVC = [[GKDYListPlayerController alloc] init];
    [list enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL * _Nonnull stop) {
        GKDYVideoModel *model = [[GKDYVideoModel alloc] initWithModel:obj];
        model.source_name = self.headerView.model.author;
        model.author_avatar = self.headerView.model.author_icon;
        [listVC.videoList addObject:model];
    }];
    listVC.index = index;
    listVC.delegate = self;
//    listVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    [self presentViewController:listVC animated:YES completion:nil];
    
//    UINavigationController *nav = [UINavigationController rootVC:listVC];
//    nav.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    GKDYPlayerNavigationController *nav = [GKDYPlayerNavigationController rootVC:listVC];
    [self presentViewController:nav animated:YES completion:nil];
    
    
//    GKDYScaleVideoView *videoView = [[GKDYScaleVideoView alloc] initWithFrame:self.view.bounds];
//    
//    [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
//        GKDYVideoModel *model = [[GKDYVideoModel alloc] initWithModel:obj];
//        model.source_name = self.headerView.model.author;
//        model.author_avatar = self.headerView.model.author_icon;
//        [videoView.videoList addObject:model];
//    }];
//    
//    @weakify(self);
//    [videoView setRequestBlock:^{
//        @strongify(self);
//        [self requestMoreList];
//    }];
//    
//    videoView.vc = self;
//    videoView.index = index;
//    [videoView show];
//    self.videoView = videoView;
}

- (void)requestMoreList {
    @weakify(self);
    [self.currentListVC requestMoreCompletion:^(NSArray * _Nonnull list) {
        @strongify(self);
        
        [list enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            GKDYVideoModel *model = [[GKDYVideoModel alloc] initWithModel:obj];
            model.source_name = self.headerView.model.author;
            model.author_avatar = self.headerView.model.author_icon;
            [self.videoView.videoList addObject:model];
        }];
        [self.videoView reloadData];
    }];
}

#pragma mark - GKDYListPlayerControllerDelegate
- (UIView *)sourceViewWithIndex:(NSInteger)index {
    UICollectionViewCell *cell = [self.currentListVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
    if ([self.currentListVC.collectionView.visibleCells containsObject:cell]) {
        return cell;
    }
    return nil;
}

#pragma mark - Lazy
- (UILabel *)titleView {
    if (!_titleView) {
        _titleView = [[UILabel alloc] init];
        _titleView.font = [UIFont systemFontOfSize:18];
        _titleView.textColor = UIColor.whiteColor;
        _titleView.textAlignment = NSTextAlignmentCenter;
        _titleView.alpha = 0;
        _titleView.text = self.model.source_name;
    }
    return _titleView;
}

- (GKPageSmoothView *)smoothView {
    if (!_smoothView) {
        _smoothView = [[GKPageSmoothView alloc] initWithDataSource:self];
        _smoothView.delegate = self;
        _smoothView.ceilPointHeight = GK_STATUSBAR_NAVBAR_HEIGHT;
        _smoothView.listCollectionView.gk_openGestureHandle = YES;
        _smoothView.holdUpScrollView = YES;
    }
    return _smoothView;
}

- (GKDYUserHeaderView *)headerView {
    if (!_headerView) {
        _headerView = [[GKDYUserHeaderView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, kDYUserHeaderHeight)];
    }
    return _headerView;
}

- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 40)];
        _categoryView.backgroundColor = GKColorRGB(34, 33, 37);
        _categoryView.titles = @[@"作品 129", @"动态 129", @"喜欢 591"];
        _categoryView.titleColor = UIColor.grayColor;
        _categoryView.titleSelectedColor = UIColor.whiteColor;
        _categoryView.titleFont = [UIFont systemFontOfSize:16];
        _categoryView.titleSelectedFont = [UIFont systemFontOfSize:16];
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorColor = UIColor.yellowColor;
        lineView.indicatorWidth = 80;
        lineView.indicatorCornerRadius = 0;
        lineView.lineStyle = JXCategoryIndicatorLineStyle_Normal;
        _categoryView.indicators = @[lineView];
        
        // 添加分割线
        UIView *btmLineView = [[UIView alloc] init];
        btmLineView.frame = CGRectMake(0, 40-0.5, _categoryView.frame.size.width, 0.5);
        btmLineView.backgroundColor = GKColorGray(200);
        [_categoryView addSubview:btmLineView];
    }
    return _categoryView;
}

@end
