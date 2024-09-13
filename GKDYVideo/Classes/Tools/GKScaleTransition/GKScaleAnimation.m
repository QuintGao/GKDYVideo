//
//  GKScaleAnimation.m
//  GKDYVideo
//
//  Created by QuintGao on 2024/9/12.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKScaleAnimation.h"
#import "GKScaleTransition.h"

@interface GKScaleAnimation()

@property (nonatomic, assign) GKScaleType type;

@property (nonatomic, weak) GKScaleTransition *transition;

@property (nonatomic, weak) UIViewController *fromVC;
@property (nonatomic, weak) UIViewController *toVC;

@end

@implementation GKScaleAnimation

- (instancetype)initWithType:(GKScaleType)type transition:(nonnull GKScaleTransition *)transition {
    if (self = [super init]) {
        self.type = type;
        self.transition = transition;
    }
    return self;
}

#pragma mark - UIViewControllerAnimatedTransitioning
- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext {
    return 0.25;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext {
    self.fromVC = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    self.toVC = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    switch (self.type) {
        case GKScaleType_Present:
            [self presentAnimation:transitionContext];
            break;
        case GKScaleType_Dismiss:
            [self dismissAnimation:transitionContext];
            break;
    }
}

- (void)presentAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    UIView *containerView = transitionContext.containerView;
    [containerView addSubview:self.toVC.view];
    
    UIView *cell = nil;
    if ([self.transition.delegate respondsToSelector:@selector(sourceView)]) {
        cell = self.transition.delegate.sourceView;
    }
    
    __block UIView *snapshotView = [cell snapshotViewAfterScreenUpdates:NO];
    if (snapshotView) {
        snapshotView.frame = self.toVC.view.bounds;
        [self.toVC.view addSubview:snapshotView];
    }
    
    CGRect initialFrame = [cell.superview convertRect:cell.frame toView:self.fromVC.view];
    CGRect finalFrame = [transitionContext finalFrameForViewController:self.toVC];
    
    self.toVC.view.center = CGPointMake(initialFrame.origin.x + initialFrame.size.width / 2, initialFrame.origin.y + initialFrame.size.height / 2);
    self.toVC.view.transform = CGAffineTransformMakeScale(initialFrame.size.width/finalFrame.size.width, initialFrame.size.height/finalFrame.size.height);
    
    UIViewController *toTopVC = nil;
    if ([self.toVC isKindOfClass:UINavigationController.class]) {
        toTopVC = [(UINavigationController *)self.toVC topViewController];
        [toTopVC beginAppearanceTransition:YES animated:YES];
    }
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
//                          delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.2 options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
        self.toVC.view.center = CGPointMake(finalFrame.origin.x + finalFrame.size.width/2, finalFrame.origin.y + finalFrame.size.height/2);
        self.toVC.view.transform = CGAffineTransformMakeScale(1, 1);
        snapshotView.alpha = 0;
    } completion:^(BOOL finished) {
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        if (toTopVC) {
            [toTopVC endAppearanceTransition];
        }
        if (snapshotView) {
            [snapshotView removeFromSuperview];
            snapshotView = nil;
        }
    }];
}

- (void)dismissAnimation:(id<UIViewControllerContextTransitioning>)transitionContext {
    __block UIView *snapshotView;
    CGRect finalFrame;
    CGFloat scaleRatio;
    
    UIView *cell = nil;
    if ([self.transition.delegate respondsToSelector:@selector(sourceView)]) {
        cell = self.transition.delegate.sourceView;
    }
    if (cell) {
        snapshotView = [cell snapshotViewAfterScreenUpdates:NO];
        snapshotView.layer.zPosition = 20;
        
        scaleRatio = self.fromVC.view.frame.size.width / cell.frame.size.width;
        finalFrame = [cell.superview convertRect:cell.frame toView:self.toVC.view];
    }else {
        snapshotView = [self.fromVC.view snapshotViewAfterScreenUpdates:NO];
        CGSize toSize = self.toVC.view.frame.size;
        scaleRatio = self.fromVC.view.frame.size.width / toSize.width;
        finalFrame = CGRectMake((toSize.width - 5)/2, (toSize.height - 5)/2, 5, 5);
    }
    
    UIView *containerView = transitionContext.containerView;
    [containerView addSubview:snapshotView];
    
    self.fromVC.view.alpha = 0;
    snapshotView.center = self.fromVC.view.center;
    snapshotView.transform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
    
    NSTimeInterval duration = [self transitionDuration:transitionContext];
    [UIView animateWithDuration:duration
//                          delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut
                     animations:^{
        snapshotView.transform = CGAffineTransformMakeScale(scaleRatio, scaleRatio);
        snapshotView.frame = finalFrame;
        snapshotView.alpha = 1;
    } completion:^(BOOL finished) {
        [transitionContext finishInteractiveTransition];
        [transitionContext completeTransition:!transitionContext.transitionWasCancelled];
        [snapshotView removeFromSuperview];
        snapshotView = nil;
        [self.transition dismiss];
    }];
}

@end
