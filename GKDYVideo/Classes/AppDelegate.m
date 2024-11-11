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
#import "GKDYMainViewController.h"
#import <SDWebImage/SDWebImage.h>
#import <SDWebImageWebPCoder/SDWebImageWebPCoder.h>
#import <ZFPlayer/ZFLandscapeRotationManager.h>
#import "GKRotationManager.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [self setupNavBarStyle];
    
    [self setupKeyWindow];
    
    [self setupWebpSupprot];
    
    [self setupNetworkCheck];
    
    return YES;
}

- (void)setupNavBarStyle {
    [GKConfigure setupCustomConfigure:^(GKNavigationBarConfigure *configure) {
        configure.backStyle             = GKNavigationBarBackStyleWhite;
        configure.titleFont             = [UIFont systemFontOfSize:18.0f];
        configure.titleColor            = [UIColor whiteColor];
        configure.gk_navItemLeftSpace   = 12.0f;
        configure.gk_navItemRightSpace  = 12.0f;
        configure.statusBarStyle        = UIStatusBarStyleLightContent;
    }];
    
    [GKGestureConfigure setupCustomConfigure:^(GKGestureHandleConfigure * _Nonnull configure) {
        configure.gk_scaleX             = 0.90f;
        configure.gk_scaleY             = 0.95f;
    }];
}

- (void)setupKeyWindow {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = [UIColor whiteColor];
    
//    GKDYNavigationController *nav = [GKDYNavigationController rootVC:[GKDYShootViewController new]];
//    nav.gk_openScrollLeftPush = YES; // 开启左滑push功能
    
    GKDYNavigationController *nav = [GKDYNavigationController rootVC:[GKDYMainViewController new]];
    self.window.rootViewController = nav;
    [self.window makeKeyAndVisible];
}

- (void)setupWebpSupprot {
    // Add WebPCoder
    SDImageWebPCoder *webPCoder = [SDImageWebPCoder sharedCoder];
    [[SDImageCodersManager sharedManager] addCoder:webPCoder];
    
    // Modify HTTP Accept Header
    [[SDWebImageDownloader sharedDownloader] setValue:@"image/webp,image/*,*/*;q=0.8" forHTTPHeaderField:@"Accept"];
}

- (void)setupNetworkCheck {
    AFNetworkReachabilityManager *networkManger = [AFNetworkReachabilityManager sharedManager];
    [networkManger startMonitoring];
    [networkManger setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
        if (status == AFNetworkReachabilityStatusReachableViaWWAN || status == AFNetworkReachabilityStatusReachableViaWiFi) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"NetworkChange" object:nil];
        }else {
            NSLog(@"无网络");
        }
    }];
}

- (UIInterfaceOrientationMask)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    GKInterfaceOrientationMask mask = [GKRotationManager supportedInterfaceOrientationsForWindow:window];
    if (mask != GKInterfaceOrientationMaskUnknow) {
        return (UIInterfaceOrientationMask)mask;
    }
    
    ZFInterfaceOrientationMask orientationMask = [ZFLandscapeRotationManager supportedInterfaceOrientationsForWindow:window];
    if (orientationMask != ZFInterfaceOrientationMaskUnknow) {
        return (UIInterfaceOrientationMask)orientationMask;
    }
    return UIInterfaceOrientationMaskPortrait;
}

@end
