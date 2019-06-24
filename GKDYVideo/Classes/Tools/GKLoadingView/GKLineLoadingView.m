//
//  GKLineLoadingView.m
//  GKDYVideo
//
//  Created by gaokun on 2019/5/7.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKLineLoadingView.h"

#define GKLineLoadingDuration  0.75
#define GKLineLoadingLineColor [UIColor whiteColor]

@implementation GKLineLoadingView

+ (void)showLoadingInView:(UIView *)view withLineHeight:(CGFloat)lineHeight {
    GKLineLoadingView *loadingView = [[GKLineLoadingView alloc] initWithFrame:view.frame lineHeight:lineHeight];
    [view addSubview:loadingView];
    [loadingView startLoading];
}

+ (void)hideLoadingInView:(UIView *)view {
    NSEnumerator *subviewsEnum = [view.subviews reverseObjectEnumerator];
    for (UIView *subView in subviewsEnum) {
        if ([subView isKindOfClass:[GKLineLoadingView class]]) {
            GKLineLoadingView *loadingView = (GKLineLoadingView *)subView;
            [loadingView stopLoading];
            [loadingView removeFromSuperview];
        }
    }
}

- (instancetype)initWithFrame:(CGRect)frame lineHeight:(CGFloat)lineHeight {
    if (self = [super initWithFrame:frame]) {
        self.backgroundColor = GKLineLoadingLineColor;
        
        self.center = CGPointMake(frame.size.width * 0.5f, frame.size.height * 0.5f);
        self.bounds = CGRectMake(0, 0, 1.0f, lineHeight);
    }
    return self;
}

- (void)startLoading {
    [self stopLoading];
    
    self.hidden = NO;
    // 创建动画组
    CAAnimationGroup *animationGroup = [CAAnimationGroup animation];
    animationGroup.duration = GKLineLoadingDuration;
    animationGroup.beginTime = CACurrentMediaTime();
    animationGroup.repeatCount = MAXFLOAT;
    animationGroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    
    // x轴缩放动画（transform.scale是以view的中心点为中心开始缩放的）
    CABasicAnimation *scaleAnimation = [CABasicAnimation animation];
    scaleAnimation.keyPath = @"transform.scale.x";
    scaleAnimation.fromValue = @(1.0f);
    scaleAnimation.toValue = @(1.0f * self.superview.frame.size.width);
    
    // 透明度渐变动画
    CABasicAnimation *alphaAnimation = [CABasicAnimation animation];
    alphaAnimation.keyPath = @"opacity";
    alphaAnimation.fromValue = @(1.0f);
    alphaAnimation.toValue = @(0.5f);
    
    animationGroup.animations = @[scaleAnimation, alphaAnimation];
    // 添加动画
    [self.layer addAnimation:animationGroup forKey:nil];
}

- (void)stopLoading {
    [self.layer removeAllAnimations];
    self.hidden = YES;
}

@end
