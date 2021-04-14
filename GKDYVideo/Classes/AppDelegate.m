//
//  AppDelegate.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "AppDelegate.h"
#import "GKDYHomeViewController.h"
#import "GKDYShootViewController.h"
#import "GKDYNavigationController.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [GKConfigure setupCustomConfigure:^(GKNavigationBarConfigure *configure) {
        configure.backStyle             = GKNavigationBarBackStyleWhite;
        configure.titleFont             = [UIFont systemFontOfSize:18.0f];
        configure.titleColor            = [UIColor whiteColor];
        configure.gk_navItemLeftSpace   = 12.0f;
        configure.gk_navItemRightSpace  = 12.0f;
        configure.statusBarStyle        = UIStatusBarStyleLightContent;
    }];
    
    [GKGestureConfigure setupCustomConfigure:^(GKGestureHandleConfigure * _Nonnull configure) {
        configure.gk_translationX       = 10.0f;
        configure.gk_translationY       = 15.0f;
        configure.gk_scaleX             = 0.90f;
        configure.gk_scaleY             = 0.95f;
    }];
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
    GKDYNavigationController *nav = [GKDYNavigationController rootVC:[GKDYShootViewController new]];
    
//    GKDYNavigationController *nav = [GKDYNavigationController rootVC:[GKDYHomeViewController new] translationScale:NO];
    nav.gk_openScrollLeftPush = YES; // 开启左滑push功能
    nav.navigationBar.hidden = YES;
    
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
    
    return YES;
}

@end
