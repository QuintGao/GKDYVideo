//
//  UITabBar+GKCategory.h
//  GKDYVideo
//
//  Created by QuintGao on 2019/10/24.
//  Copyright © 2019 GKDYVideo. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UITabBar (GKCategory)

@end

NS_ASSUME_NONNULL_END

#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 130000

UIKIT_EXTERN API_AVAILABLE(ios(13.0), tvos(13.0)) @interface UITabBarAppearance (QMUI)

/**
 同时设置 stackedLayoutAppearance、inlineLayoutAppearance、compactInlineLayoutAppearance 三个状态下的 itemAppearance
 */
- (void)ay_applyItemAppearanceWithBlock:(void (^ _Nullable)(UITabBarItemAppearance * _Nullable itemAppearance))block;
@end

#endif
