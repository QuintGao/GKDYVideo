//
//  GKDYTabBar.h
//  GKDYVideo
//
//  Created by gaokun on 2019/5/8.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKDYTabBarStyle) {
    GKDYTabBarStyleTransparent, // 全透明样式
    GKDYTabBarStyleTranslucent  // 半透明样式
};

@interface GKDYTabBar : UITabBar

@property (nonatomic, assign) GKDYTabBarStyle style;

- (void)showLine;
- (void)hideLine;

@end

NS_ASSUME_NONNULL_END
