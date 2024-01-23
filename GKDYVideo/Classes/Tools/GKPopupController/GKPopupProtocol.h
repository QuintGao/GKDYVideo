//
//  GKPopupProtocol.h
//  Pods
//
//  Created by QuintGao on 2024/1/12.
//

#import <UIKit/UIKit.h>

@class GKPopupController;

@protocol GKPopupProtocol <NSObject>

@property (nonatomic, weak) GKPopupController *popupController;

@required

// 内容视图
- (UIView *)contentView;

// 内容视图高度
- (CGFloat)contentHeight;

@optional

// 是否需要添加导航控制器，默认YES
- (BOOL)needAddNavigationController;

// 显示或隐藏时的动画时间，默认0.25
- (NSTimeInterval)animationDuration;

// 背景色，默认黑色0.5透明度
- (UIColor *)backColor;

// 是否允许点击背景隐藏,默认YES
- (BOOL)allowsTapBackgroundToDismiss;

// 是否支持滑动返回（包括下滑和右滑），默认YES
- (BOOL)allowsSlideToDismiss;

// 是否支持右滑返回，默认YES
- (BOOL)allowsRightSlideToDismiss;

// 滑动返回时的速度阈值，超过此阈值会dismiss，默认300
- (CGFloat)velocityThreshold;

// 滑动返回时的平移阈值，超过此阈值会dismiss，默认contentView高度的一半
- (CGFloat)translationThreshold;

// 滑动开始
- (void)panSlideBegan;

// 滑动中，滑动比例
- (void)panSlideChangeWithRatio:(CGFloat)ratio;

// 滑动结束，isShow是否显示
- (void)panSlideEnded:(BOOL)isShow;

- (void)contentViewWillShow;

- (void)contentViewShowAnimation;

- (void)contentViewDidShow;

- (void)contentViewWillDismiss;

- (void)contentViewDismissAnimation;

- (void)contentViewDidDismiss;

- (void)refreshContentViewAnimation;

@end
