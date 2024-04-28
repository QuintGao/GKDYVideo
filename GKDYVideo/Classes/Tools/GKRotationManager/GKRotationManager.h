//
//  GKRotationManager.h
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKLandscapeWindow.h"
#import "GKLandscapeViewController.h"

typedef NS_OPTIONS(NSUInteger, GKInterfaceOrientationMask) {
    GKInterfaceOrientationMaskUnknow = 0,
    GKInterfaceOrientationMaskPortrait = (1 << UIInterfaceOrientationPortrait),
    GKInterfaceOrientationMaskLandscapeLeft = (1 << UIInterfaceOrientationLandscapeLeft),
    GKInterfaceOrientationMaskLandscapeRight = (1 << UIInterfaceOrientationLandscapeRight),
    GKInterfaceOrientationMaskPortraitUpsideDown = ( 1 << UIInterfaceOrientationPortraitUpsideDown),
    GKInterfaceOrientationMaskLandscape = (GKInterfaceOrientationMaskLandscapeLeft | GKInterfaceOrientationMaskLandscapeRight),
    GKInterfaceOrientationMaskAll = (GKInterfaceOrientationMaskPortrait | GKInterfaceOrientationMaskLandscapeLeft | GKInterfaceOrientationMaskLandscapeRight | GKInterfaceOrientationMaskPortraitUpsideDown),
    GKInterfaceOrientationMaskAllButUpsideDown = (GKInterfaceOrientationMaskPortrait | GKInterfaceOrientationMaskLandscapeLeft | GKInterfaceOrientationMaskLandscapeRight)
};

NS_ASSUME_NONNULL_BEGIN

@interface GKRotationManager : NSObject

+ (GKInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window;
+ (instancetype)rotationManager;
- (instancetype)init NS_UNAVAILABLE;
- (instancetype)new NS_UNAVAILABLE;

/// 横屏时的window
@property (nonatomic, strong, nullable) GKLandscapeWindow *window;

/// 需要旋转的内容视图
@property (nonatomic, weak) UIView *contentView;

/// 旋转内容原来的父视图
@property (nonatomic, weak) UIView *containerView;

/// 是否允许自动旋转
@property (nonatomic, assign) BOOL allowOrientationRotation;

/// 自动旋转支持的方向
@property (nonatomic, assign) GKInterfaceOrientationMask supportInterfaceOrientation;

/// 当前的方向
@property (nonatomic, assign) UIInterfaceOrientation currentOrientation;

/// 是否全屏
@property (nonatomic, assign, readonly) BOOL isFullscreen;

/// 动画时长
@property (nonatomic, assign) NSTimeInterval animationDuration;

/// 即将旋转回调
@property (nonatomic, copy, nullable) void(^orientationWillChange)(BOOL isFullscreen);

/// 结束旋转回调
@property (nonatomic, copy, nullable) void(^orientationDidChanged)(BOOL isFullscreen);

/// 旋转
- (void)rotate;

/// 旋转到指定方向
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated;

/// 旋转到指定方向
- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated completion:(void(^ __nullable)(void))completion;

@end

@interface GKRotationManager (Internal)

/// 当前设备方向
@property (nonatomic, assign, readonly) UIInterfaceOrientation currentDeviceOrientation;

/// 旋转时是否禁止动画
@property (nonatomic, assign) BOOL disableAnimations;

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window;

- (UIInterfaceOrientation)getCurrentOrientation;

- (__kindof GKLandscapeViewController *)landscapeViewController;

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation completion:(void (^ __nullable)(void))completion;

- (void)handleDeviceOrientationChange;

- (BOOL)isSupportInterfaceOrientation:(UIInterfaceOrientation)orientation;

- (void)willChangeOrientation:(UIInterfaceOrientation)orientation;

- (void)didChangeOrientation:(UIInterfaceOrientation)orientation;

@end

NS_ASSUME_NONNULL_END

#pragma mark - fix safe area

NS_ASSUME_NONNULL_BEGIN
typedef NS_OPTIONS(NSUInteger, GKSafeAreaInsetsMask) {
    GKSafeAreaInsetsMaskNone = 0,
    GKSafeAreaInsetsMaskTop = 1 << 0,
    GKSafeAreaInsetsMaskLeft = 1 << 1,
    GKSafeAreaInsetsMaskBottom = 1 << 2,
    GKSafeAreaInsetsMaskRight = 1 << 3,
    
    GKSafeAreaInsetsMaskHorizontal = GKSafeAreaInsetsMaskLeft | GKSafeAreaInsetsMaskRight,
    GKSafeAreaInsetsMaskVertical = GKSafeAreaInsetsMaskTop | GKSafeAreaInsetsMaskBottom,
    GKSafeAreaInsetsMaskAll = GKSafeAreaInsetsMaskHorizontal | GKSafeAreaInsetsMaskVertical
}API_DEPRECATED("deprecated!", ios(13.0, 16.0));

API_DEPRECATED("deprecated!", ios(13.0, 16.0)) @interface UIViewController (GKRotationSafeAreaFixing)
/// 禁止调整哪些方向的安全区域
@property (nonatomic) GKSafeAreaInsetsMask disabledAdjustSafeAreaInsetsMask;
@end

NS_ASSUME_NONNULL_END
