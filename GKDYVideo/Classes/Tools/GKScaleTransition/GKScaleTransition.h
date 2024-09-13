//
//  GKScaleTransition.h
//  GKDYVideo
//
//  Created by QuintGao on 2024/9/12.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GKScaleTransitionDelegate <NSObject>

@optional

/// 来源视图，用于显示及恢复
@property (nonatomic, weak, nullable) UIView *sourceView;

/// 横向滑动的scrollView，解决滑动冲突
@property (nonatomic, weak, nullable) UIScrollView *horizontalScrollView;

/// 滑动开始
- (void)transitionPanBegan;

/// 滑动改变
- (void)transitionPanChange;

/// 滑动结束
- (void)transitionPanEnded:(BOOL)isDismiss;

@end

@interface GKScaleTransition : UIPercentDrivenInteractiveTransition

@property (nonatomic, weak) id<GKScaleTransitionDelegate> delegate;

+ (void)connectToViewController:(UIViewController *)viewController;
- (void)connectToViewController:(UIViewController *)viewController;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
