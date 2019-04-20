//
//  GKDYListViewController.m
//  GKDYVideo
//
//  Created by gaokun on 2018/12/14.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYListViewController.h"
#import "GKDYListCollectionViewCell.h"
#import "GKDYPlayerViewController.h"

@interface GKDYListViewController ()<UICollectionViewDataSource, UICollectionViewDelegate>

@property (nonatomic, strong) UICollectionView  *collectionView;

@property (nonatomic, strong) NSArray           *videos;

@property (nonatomic, copy) void(^scrollCallback)(UIScrollView *scrollView);

@property (nonatomic, assign) BOOL              isRefresh;

@end

@implementation GKDYListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
    
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    self.collectionView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
        // 模拟刷新，获取本地数据
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"json"];
            
            NSData *jsonData = [NSData dataWithContentsOfFile:videoPath];
            
            NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
            
            NSArray *videoList = dic[@"data"][@"video_list"];
            
            NSMutableArray *array = [NSMutableArray new];
            for (NSDictionary *dict in videoList) {
                GKDYVideoModel *model = [GKDYVideoModel yy_modelWithDictionary:dict];
                [array addObject:model];
            }
            
            self.isRefresh = YES;
            
            self.videos = array;
            
            [self.collectionView.mj_header endRefreshing];
            
            [self.collectionView reloadData];
        });
    }];
}

- (void)refreshData {
    if (self.isRefresh) return;
    
    [self.collectionView.mj_header beginRefreshing];
}

#pragma mark - <UICollectionViewDataSource, UICollectionViewDelegate>
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.videos.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    GKDYListCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"GKDYListCollectionViewCell" forIndexPath:indexPath];
    cell.model = self.videos[indexPath.row];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    GKDYPlayerViewController *playerVC = [[GKDYPlayerViewController alloc] initWithVideos:self.videos index:indexPath.item];
    [self.navigationController pushViewController:playerVC animated:YES];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    !self.scrollCallback ? : self.scrollCallback(scrollView);
}

#pragma mark - GKPageListViewDelegate
- (UIScrollView *)listScrollView {
    return self.collectionView;
}

- (void)listViewDidScrollCallback:(void (^)(UIScrollView *))callback {
    self.scrollCallback = callback;
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
    }
    return _collectionView;
}

@end
