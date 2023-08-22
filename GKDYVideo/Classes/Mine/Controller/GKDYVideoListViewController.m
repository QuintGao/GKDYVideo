//
//  GKDYVideoListViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoListViewController.h"
#import "GKDYVideoListCell.h"
#import "GKDYUserVideoViewModel.h"
#import "GKBallLoadingView.h"

@interface GKDYVideoListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) GKDYUserVideoViewModel *viewModel;

@property (nonatomic, strong) UIView *loadingBgView;
@property (nonatomic, strong) GKBallLoadingView *loadingView;

@end

@implementation GKDYVideoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initUI];
    [self setupRefresh];
}

- (void)initUI {
    [self.view addSubview:self.collectionView];
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.collectionView addSubview:self.loadingBgView];
    self.loadingBgView.frame = CGRectMake(0, 0, self.view.frame.size.width, 200);
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    self.view.frame = self.view.superview.bounds;
}

- (void)setupRefresh {
    @weakify(self);
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        @strongify(self);
        [self.viewModel requestData];
    }];
}

- (void)requestData {
    self.loadingView = [GKBallLoadingView loadingViewInView:self.loadingBgView];
    [self.loadingView startLoading];
    [self.viewModel requestData];
}

- (void)reloadData {
    [self.collectionView.mj_footer endRefreshing];
    if (!self.viewModel.hasMore) {
        [self.collectionView.mj_footer endRefreshingWithNoMoreData];
    }
    [self.collectionView reloadData];
}

- (void)scrollItemToIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.item > self.viewModel.dataList.count - 1) return;
    
//    GKDYVideoListCell *cell = [self.collectionView cellForItemAtIndexPath:indexPath];
//    if ([self.collectionView.visibleCells containsObject:cell]) {
//        return;
//    }
    
    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
//    if (indexPath.row >= self.viewModel.dataList.count - 3) {
//        [self.viewModel requestData];
//    }
}

- (void)requestMoreCompletion:(void (^)(NSArray * _Nonnull))completion {
    [self.viewModel requestDataCompletion:^(BOOL success, NSArray * _Nullable list) {
        [self reloadData];
        !completion ?: completion(list);
    }];
}

#pragma mark - GKPageSmoothListViewDelegate
- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.collectionView;
}

- (void)listViewDidAppear {
    if ([self.viewModel.ctime isEqualToString:@""]) {
        [self requestData];
    }
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.viewModel.dataList.count;
}

- (__kindof UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GKDYVideoListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GKDYVideoListCell" forIndexPath:indexPath];
    cell.model = self.viewModel.dataList[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.item;
    !self.cellClickBlock ?: self.cellClickBlock(self.viewModel.dataList, indexPath.item);
}

#pragma mark - Lazy
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat width = (self.view.bounds.size.width - 2) / 3;
        CGFloat height = width * 16 / 9;
        UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
        layout.itemSize = CGSizeMake(width, height);
        layout.minimumLineSpacing = 1.0f;
        layout.minimumInteritemSpacing = 1.0f;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = UIColor.blackColor;
        [_collectionView registerClass:GKDYVideoListCell.class forCellWithReuseIdentifier:@"GKDYVideoListCell"];
        _collectionView.alwaysBounceVertical = YES;
        _collectionView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    return _collectionView;
}

- (GKDYUserVideoViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [[GKDYUserVideoViewModel alloc] init];
        _viewModel.uid = self.uid;
        
        @weakify(self);
        [_viewModel setRequestBlock:^(BOOL success) {
            @strongify(self);
            [self reloadData];
            if (self.loadingView) {
                [self.loadingView stopLoading];
                [self.loadingView removeFromSuperview];
            }
            self.loadingBgView.hidden = YES;
        }];
    }
    return _viewModel;
}

- (UIView *)loadingBgView {
    if (!_loadingBgView) {
        _loadingBgView = [[UIView alloc] init];
    }
    return _loadingBgView;
}

@end
