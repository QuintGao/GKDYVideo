//
//  GKDYListViewController.m
//  GKDYVideo
//
//  Created by gaokun on 2018/12/14.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYListViewController.h"
#import "GKDYListCollectionViewCell.h"
#import "GKBallLoadingView.h"

@interface GKDYListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, strong) UIView            *loadingBgView;

@property (nonatomic, strong) NSMutableArray    *videos;

@property (nonatomic, assign) BOOL              isRefresh;
@property (nonatomic, assign) NSInteger         index;

@end

@implementation GKDYListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
    
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.collectionView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
        self.index ++ ;
        
        NSString *fileName = [NSString stringWithFormat:@"video%zd", self.index];
        NSString *videoPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
        NSData *jsonData = [NSData dataWithContentsOfFile:videoPath];
        
        if (!jsonData) {
            [self.collectionView.mj_footer endRefreshingWithNoMoreData];
            return;
        }
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *videoList = dic[@"data"];
        
        NSMutableArray *array = [NSMutableArray array];
        for (NSDictionary *dict in videoList) {
            GKAWEModel *model = [GKAWEModel yy_modelWithDictionary:dict];
            [array addObject:model];
        }
        
        [self.videos addObjectsFromArray:array];
        [self.collectionView reloadData];
        
        [self.collectionView.mj_footer endRefreshing];
    }];
    
    [self.collectionView addSubview:self.loadingBgView];
    self.loadingBgView.frame = CGRectMake(0, 0, SCREEN_WIDTH, ADAPTATIONRATIO * 400.0f);
    
    // 模拟数据加载
    GKBallLoadingView *loadingView = [GKBallLoadingView loadingViewInView:self.loadingBgView];
    [loadingView startLoading];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [loadingView stopLoading];
        [loadingView removeFromSuperview];
        self.loadingBgView.hidden = YES;
        self.index = 1;
        
        NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"json"];
        
        NSData *jsonData = [NSData dataWithContentsOfFile:videoPath];
        
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
        
        NSArray *videoList = dic[@"data"];
        
        NSMutableArray *array = [NSMutableArray new];
        for (NSDictionary *dict in videoList) {
            GKAWEModel *model = [GKAWEModel yy_modelWithDictionary:dict];
            [array addObject:model];
        }
        
        self.isRefresh = YES;
        
        [self.videos removeAllObjects];
        [self.videos addObjectsFromArray:array];
        
        [self.collectionView.mj_header endRefreshing];
        !self.refreshBlock ? : self.refreshBlock();
        [self.collectionView reloadData];
    });
}

- (void)refreshData {
    if (self.isRefresh) return;
    
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    self.collectionView.mj_footer.hidden = self.videos.count == 0;
    return self.videos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GKDYListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GKDYListCollectionViewCell" forIndexPath:indexPath];
    cell.model = self.videos[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    self.selectedIndex = indexPath.item;
    !self.itemClickBlock ? : self.itemClickBlock(self.videos, indexPath.item);
}

#pragma mark - GKPageSmoothListViewDelegate
- (UIView *)listView {
    return self.view;
}

- (UIScrollView *)listScrollView {
    return self.collectionView;
}

#pragma mark - 懒加载
- (UICollectionView *)collectionView {
    if (!_collectionView) {
        CGFloat width = (SCREEN_WIDTH - 2) / 3;
        CGFloat height = width * 16 / 9;
        UICollectionViewFlowLayout *layout = [UICollectionViewFlowLayout new];
        layout.itemSize = CGSizeMake(width, height);
        layout.minimumLineSpacing = 1.0f;
        layout.minimumInteritemSpacing = 1.0f;
        
        _collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:layout];
        _collectionView.dataSource = self;
        _collectionView.delegate = self;
        _collectionView.backgroundColor = [UIColor blackColor];
        [_collectionView registerClass:[GKDYListCollectionViewCell class] forCellWithReuseIdentifier:@"GKDYListCollectionViewCell"];
        _collectionView.alwaysBounceVertical = YES;
    }
    return _collectionView;
}

- (UIView *)loadingBgView {
    if (!_loadingBgView) {
        _loadingBgView = [UIView new];
    }
    return _loadingBgView;
}

- (NSMutableArray *)videos {
    if (!_videos) {
        _videos = [NSMutableArray new];
    }
    return _videos;
}

@end
