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
#import "GKDYTabBar.h"
#import "UITabBar+GKCategory.h"
#import "GKDYHomeViewController.h"

@interface GKDYMainViewController ()<UITabBarControllerDelegate, GKDYPlayerViewControllerDelegate, GKViewControllerPopDelegate>

@property (nonatomic, strong) GKDYTabBar    *dyTabBar;

@end

@implementation GKDYMainViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.delegate = self;
    
    // 替换系统tabbar
    self.dyTabBar = [GKDYTabBar new];
    self.dyTabBar.translucent = NO;
    [self setValue:self.dyTabBar forKey:@"tabBar"];
    
    self.playerVC = [GKDYPlayerViewController new];
    self.playerVC.delegate = self;
    
//    [self addChildVC:self.playerVC title:@"首页"];
    [self addChildVC:[GKDYHomeViewController new] title:@"首页"];
    [self addChildVC:[GKDYAttentViewController new] title:@"关注"];
    [self addChildVC:[GKDYMessageViewController new] title:@"消息"];
    [self addChildVC:[GKDYMineViewController new] title:@"我"];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)addChildVC:(UIViewController *)childVC title:(NSString *)title {
    childVC.tabBarItem.title = title;
    [self setTabbarStyle:GKDYTabBarStyleTranslucent vc:childVC];

    childVC.tabBarItem.titlePositionAdjustment = UIOffsetMake(0, -100);
    childVC.tabBarItem.imageInsets = UIEdgeInsetsMake(28, 0, -28, 0);
    
    GKDYNavigationController *nav = [GKDYNavigationController rootVC:childVC];
    nav.gk_openScrollLeftPush = YES;
    [self addChildViewController:nav];
}

- (void)setTabbarStyle:(GKDYTabBarStyle)style vc:(UIViewController *)vc {
    self.dyTabBar.style = style;
    
    UIImage *normalImage = [UIImage gk_imageWithColor:UIColor.clearColor size:CGSizeMake(1, 1)];;
    UIImage *selectImage = [UIImage gk_imageWithColor:[UIColor whiteColor] size:CGSizeMake(36, 3)];
    UIColor *normalTitleColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    UIColor *selectTitleColor = UIColor.whiteColor;
    UIFont *normalTitleFont = [UIFont boldSystemFontOfSize:15];
    UIFont *selectTitleFont = [UIFont boldSystemFontOfSize:16];
    UIImage *backgroundImage = nil;
    UIImage *shadowImage = [UIImage gk_imageWithColor:[UIColor colorWithWhite:1.0f alpha:0.2f] size:CGSizeMake(SCREEN_WIDTH, 0.5f)];;
    
    if (style == GKDYTabBarStyleTransparent) {
        backgroundImage = [UIImage gk_imageWithColor:UIColor.clearColor size:CGSizeMake(SCREEN_WIDTH, TABBAR_HEIGHT)];
    }else if (style == GKDYTabBarStyleTranslucent) {
        backgroundImage = [UIImage gk_imageWithColor:[UIColor colorWithWhite:0 alpha:0.8] size:CGSizeMake(SCREEN_WIDTH, TABBAR_HEIGHT)];
    }
    vc.tabBarItem.image = [normalImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    vc.tabBarItem.selectedImage = [selectImage imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal];
    
    NSDictionary *normalTitleAttr = @{NSFontAttributeName: normalTitleFont, NSForegroundColorAttributeName: normalTitleColor};
    NSDictionary *selectTitleAttr = @{NSFontAttributeName: selectTitleFont, NSForegroundColorAttributeName: selectTitleColor};
    if (@available(iOS 13.0, *)) {
        UITabBarAppearance *appearance = [UITabBarAppearance new];
        [appearance ay_applyItemAppearanceWithBlock:^(UITabBarItemAppearance * _Nullable itemAppearance) {
            itemAppearance.normal.titleTextAttributes = normalTitleAttr;
            itemAppearance.selected.titleTextAttributes = selectTitleAttr;
        }];
        appearance.backgroundEffect = nil;
        appearance.shadowImage = shadowImage;
        appearance.backgroundImage = backgroundImage;
        vc.tabBarItem.standardAppearance = appearance;
    }else {
        [vc.tabBarItem setTitleTextAttributes:normalTitleAttr forState:UIControlStateNormal];
        [vc.tabBarItem setTitleTextAttributes:selectTitleAttr forState:UIControlStateSelected];
    }
}

#pragma mark - GKDYPlayerViewControllerDelegate
- (void)playerVCDidClickShoot:(GKDYPlayerViewController *)playerVC {
    // 随拍按钮点击
    [self.navigationController popViewControllerAnimated:YES];
}

//- (void)playerVC:(GKDYPlayerViewController *)playerVC controlView:(nonnull GKDYVideoControlView *)controlView isCritical:(BOOL)isCritical {
//    
//    GKSliderView *sliderView = controlView.sliderView;
//    
//    if (isCritical) { // 到达临界点，隐藏分割线
//        sliderView.maximumTrackTintColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
//        [self.dyTabBar hideLine];
//    }else {
//        sliderView.maximumTrackTintColor = [UIColor clearColor];
//        [self.dyTabBar showLine];
//    }
//}

#pragma mark - UITabBarControllerDelegate
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 2 || tabBarController.selectedIndex == 3) {
        self.gk_popDelegate = self;
    }else {
        self.gk_popDelegate = nil;
    }
}

@end
