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
#import "GKDYPersonalViewController.h"
#import "GKDYScrollView.h"
#import "GKDYVideoView.h"

@interface GKDYHomeViewController()<UIScrollViewDelegate, GKViewControllerPushDelegate>

@property (nonatomic, strong) GKDYScrollView    *mainScrolView;

@property (nonatomic, strong) NSArray           *childVCs;

@property (nonatomic, strong) GKDYSearchViewController  *searchVC;
@property (nonatomic, strong) GKDYPlayerViewController  *playerVC;


@end

@implementation GKDYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden    = YES;
    
    [self.view addSubview:self.mainScrolView];
    
    self.childVCs = @[self.searchVC, self.playerVC];
    
    CGFloat scrollW = SCREEN_WIDTH;
    CGFloat scrollH = SCREEN_HEIGHT;
    self.mainScrolView.frame = CGRectMake(0, 0, scrollW, scrollH);
    self.mainScrolView.contentSize = CGSizeMake(self.childVCs.count * scrollW, scrollH);
    
    [self.childVCs enumerateObjectsUsingBlock:^(UIViewController *vc, NSUInteger idx, BOOL * _Nonnull stop) {
        [self addChildViewController:vc];
        [self.mainScrolView addSubview:vc.view];
        
        vc.view.frame = CGRectMake(idx * scrollW, 0, scrollW, scrollH);
    }];
    
    self.mainScrolView.contentOffset = CGPointMake(scrollW, 0);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    if (self.mainScrolView.contentOffset.x == SCREEN_WIDTH) {
        self.gk_statusBarHidden = YES;
    }else {
        self.gk_statusBarHidden = NO;
    }
    
    // 设置左滑push代理
    self.gk_pushDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.playerVC.videoView resume];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 取消push代理
    self.gk_pushDelegate = nil;
    
    [self.playerVC.videoView pause];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.gk_statusBarHidden = NO;
    
    // 右滑开始时暂停
    if (scrollView.contentOffset.x == SCREEN_WIDTH) {
        [self.playerVC.videoView pause];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 滑动结束，如果是播放页则恢复播放
    if (scrollView.contentOffset.x == SCREEN_WIDTH) {
        self.gk_statusBarHidden = YES;
        
        [self.playerVC.videoView resume];
    }
}

#pragma mark - GKViewControllerPushDelegate
- (void)pushToNextViewController {
    GKDYPersonalViewController *personalVC = [GKDYPersonalViewController new];
    personalVC.uid = self.playerVC.videoView.currentPlayView.model.author.user_id;
    [self.navigationController pushViewController:personalVC animated:YES];
}

#pragma mark - 懒加载
- (GKDYScrollView *)mainScrolView {
    if (!_mainScrolView) {
        _mainScrolView = [GKDYScrollView new];
        _mainScrolView.pagingEnabled = YES;
        _mainScrolView.showsHorizontalScrollIndicator = NO;
        _mainScrolView.showsVerticalScrollIndicator = NO;
        _mainScrolView.bounces = NO; // 禁止边缘滑动
        _mainScrolView.delegate = self;
        if (@available(iOS 11.0, *)) {
            _mainScrolView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        } else {
            // Fallback on earlier versions
        }
    }
    return _mainScrolView;
}

- (GKDYSearchViewController *)searchVC {
    if (!_searchVC) {
        _searchVC = [GKDYSearchViewController new];
    }
    return _searchVC;
}

- (GKDYPlayerViewController *)playerVC {
    if (!_playerVC) {
        _playerVC = [GKDYPlayerViewController new];
    }
    return _playerVC;
}

@end
