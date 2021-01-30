//
//  GKDYMainViewController.m
//  GKDYVideo
//
//  Created by gaokun on 2018/12/12.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYMainViewController.h"
#import "GKDYNavigationController.h"
#import "GKDYAttentViewController.h"
#import "GKDYMessageViewController.h"
#import "GKDYMineViewController.h"
#import "UIImage+GKCategory.h"
#import "GKDYTabBar.h"

@interface GKDYMainViewController ()<UITabBarControllerDelegate, GKDYPlayerViewControllerDelegate, GKViewControllerPopDelegate>

@property (nonatomic, strong) GKDYTabBar    *dyTabBar;

@end

@implementation GKDYMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    // 替换系统tabbar
    self.dyTabBar = [GKDYTabBar new];
    [self setValue:self.dyTabBar forKey:@"tabBar"];
    
    self.playerVC = [GKDYPlayerViewController new];
    self.playerVC.delegate = self;
    
    [self addChildVC:self.playerVC title:@"首页"];
    [self addChildVC:[GKDYAttentViewController new] title:@"关注"];
    [self addChildVC:[GKDYMessageViewController new] title:@"消息"];
    [self addChildVC:[GKDYMineViewController new] title:@"我"];
}

- (void)addChildVC:(UIViewController *)childVC title:(NSString *)title {
    childVC.tabBarItem.title = title;
    childVC.tabBarItem.image = [[UIImage gk_imageWithColor:[UIColor clearColor] size:CGSizeMake(36, 3)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVC.tabBarItem.selectedImage = [[UIImage gk_imageWithColor:[UIColor whiteColor] size:CGSizeMake(36, 3)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    childVC.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -14);
    childVC.tabBarItem.imageInsets = UIEdgeInsetsMake(28, 0, -28, 0);
    
    [childVC.tabBarItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.6]} forState:UIControlStateNormal];
    [childVC.tabBarItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0f], NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateSelected];

    GKDYNavigationController *nav = [GKDYNavigationController rootVC:childVC translationScale:NO];
    nav.gk_openScrollLeftPush = YES;
    [self addChildViewController:nav];
}

#pragma mark - GKDYPlayerViewControllerDelegate
- (void)playerVCDidClickShoot:(GKDYPlayerViewController *)playerVC {
    // 随拍按钮点击
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)playerVC:(GKDYPlayerViewController *)playerVC controlView:(nonnull GKDYVideoControlView *)controlView isCritical:(BOOL)isCritical {
    
    GKSliderView *sliderView = controlView.sliderView;
    
    if (isCritical) { // 到达临界点，隐藏分割线
        sliderView.maximumTrackTintColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
        [self.dyTabBar hideLine];
    }else {
        sliderView.maximumTrackTintColor = [UIColor clearColor];
        [self.dyTabBar showLine];
    }
}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 2 || tabBarController.selectedIndex == 3) {
        self.gk_popDelegate = self;
    }else {
        self.gk_popDelegate = nil;
    }
}

@end
