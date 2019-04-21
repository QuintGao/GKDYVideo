//
//  GKDYMainViewController.m
//  GKDYVideo
//
//  Created by gaokun on 2018/12/12.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYMainViewController.h"
#import "GKDYNavigationController.h"
#import "GKDYOtherViewController.h"
#import "UIImage+GKCategory.h"

@interface GKDYMainViewController ()<UITabBarControllerDelegate>

@end

@implementation GKDYMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    self.gk_statusBarHidden = NO;
    [self.tabBar setBackgroundImage:[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(SCREEN_WIDTH, TABBAR_HEIGHT)]];
    self.tabBar.shadowImage = [UIImage new];
    
    self.playerVC = [GKDYPlayerViewController new];
    
    [self addChildVC:self.playerVC title:@"首页"];
    [self addChildVC:[GKDYOtherViewController new] title:@"关注"];
    [self addChildVC:[GKDYOtherViewController new] title:@"消息"];
    [self addChildVC:[GKDYOtherViewController new] title:@"我的"];
}

- (void)addChildVC:(UIViewController *)childVC title:(NSString *)title {
    childVC.tabBarItem.title = title;
    childVC.tabBarItem.image = [[UIImage imageWithColor:[UIColor clearColor] size:CGSizeMake(36, 3)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    childVC.tabBarItem.selectedImage = [[UIImage imageWithColor:[UIColor whiteColor] size:CGSizeMake(36, 3)] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    childVC.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -16);
    childVC.tabBarItem.imageInsets = UIEdgeInsetsMake(26, 0, -26, 0);
    
    [childVC.tabBarItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16], NSForegroundColorAttributeName: [UIColor colorWithWhite:1.0 alpha:0.6]} forState:UIControlStateNormal];
    [childVC.tabBarItem setTitleTextAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16.0f], NSForegroundColorAttributeName: [UIColor whiteColor]} forState:UIControlStateSelected];

    GKDYNavigationController *nav = [GKDYNavigationController rootVC:childVC translationScale:NO];
    [self addChildViewController:nav];
}

@end
