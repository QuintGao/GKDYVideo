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
#import "GKDYMainViewController.h"
#import "GKDYScrollView.h"
#import "GKDYVideoView.h"
#import "UIImage+GKCategory.h"

@interface GKDYHomeViewController()<UIScrollViewDelegate, GKViewControllerPushDelegate, UITabBarControllerDelegate>

@property (nonatomic, strong) GKDYScrollView    *mainScrolView;

@property (nonatomic, strong) NSArray           *childVCs;

@property (nonatomic, strong) GKDYSearchViewController  *searchVC;
//@property (nonatomic, strong) GKDYPlayerViewController  *playerVC;
@property (nonatomic, strong) GKDYMainViewController    *mainVC;


@end

@implementation GKDYHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden    = YES;
    
    [self.view addSubview:self.mainScrolView];
    
    self.childVCs = @[self.searchVC, self.mainVC];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeToSearch:) name:@"PlayerSearchClickNotification" object:nil];
}

- (void)changeToSearch:(NSNotification *)notify {
    [self.mainScrolView setContentOffset:CGPointZero animated:YES];
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
    
    [self.mainVC.playerVC.videoView resume];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    // 取消push代理
    self.gk_pushDelegate = nil;
    
    [self.mainVC.playerVC.videoView pause];
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.gk_statusBarHidden = NO;
    
    // 右滑开始时暂停
    if (scrollView.contentOffset.x == SCREEN_WIDTH) {
        [self.mainVC.playerVC.videoView pause];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    // 滑动结束，如果是播放页则恢复播放
    if (scrollView.contentOffset.x == SCREEN_WIDTH) {
        self.gk_statusBarHidden = YES;
        
        [self.mainVC.playerVC.videoView resume];
    }
}

#pragma mark - GKViewControllerPushDelegate
- (void)pushToNextViewController {
    GKDYPersonalViewController *personalVC = [GKDYPersonalViewController new];
    personalVC.uid = self.mainVC.playerVC.videoView.currentPlayView.model.author.user_id;
    [self.navigationController pushViewController:personalVC animated:YES];
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    NSLog(@"%@", viewController.tabBarItem.title);
    
    UINavigationController *nav = (UINavigationController *)viewController;
    
    if ([nav.topViewController isKindOfClass:[GKDYPlayerViewController class]]) {
        [self.mainVC.tabBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(SCREEN_WIDTH, TABBAR_HEIGHT)]];
        
        self.gk_statusBarHidden = YES;
    }else {
        [self.mainVC.tabBar setBackgroundImage:[UIImage imageWithColor:[UIColor blackColor] size:CGSizeMake(SCREEN_WIDTH, TABBAR_HEIGHT)]];
        
        self.gk_statusBarHidden = NO;
    }
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

- (GKDYMainViewController *)mainVC {
    if (!_mainVC) {
        _mainVC = [GKDYMainViewController new];
        _mainVC.delegate = self;
    }
    return _mainVC;
}

@end
