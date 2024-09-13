//
//  GKScaleTransition.m
//  GKDYVideo
//
//  Created by QuintGao on 2024/9/12.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKScaleTransition.h"
#import "GKScaleAnimation.h"

static GKScaleTransition *_transition;

@interface GKScaleTransition()<UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate>

@property (nonatomic, weak) UIViewController *presentVC;

@property (nonatomic, assign) CGPoint viewCenter;

@property (nonatomic, assign) BOOL interacting;

@end

@implementation GKScaleTransition

+ (void)connectToViewController:(UIViewController *)viewController {
    GKScaleTransition *transition = [[GKScaleTransition alloc] init];
    [transition connectToViewController:viewController];
    _transition = transition;
}

- (void)connectToViewController:(UIViewController *)viewController {
    self.presentVC = viewController;
    
    viewController.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    viewController.transitioningDelegate = self;
    
    // 添加手势
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.delegate = self;
    [viewController.view addGestureRecognizer:pan];
}

- (void)dismiss {
    _transition = nil;
}

- (CGFloat)completionSpeed {
    return 1 - self.percentComplete;
}

- (UIScrollView *)scrollView {
    if ([self.delegate respondsToSelector:@selector(horizontalScrollView)]) {
        return self.delegate.horizontalScrollView;
    }
    return nil;
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (self.scrollView && self.scrollView.contentOffset.x > 0) {
        return NO;
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] || [otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
        if (otherGestureRecognizer.view == self.scrollView) {
            return YES;
        }
    }
    return NO;
}

#pragma mark - Handle Pan
- (void)handlePan:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:pan.view.superview];
    if (!self.interacting && (translation.x < 0 || translation.y < 0 || translation.x < translation.y)) {
        return;
    }
    switch (pan.state) {
        case UIGestureRecognizerStateBegan:
            [self handlePanBegan:pan];
            break;
        case UIGestureRecognizerStateChanged:
            [self handlePanChange:pan];
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded:
            [self handlePanEnded:pan];
            break;
        default:
            break;
    }
}

- (void)handlePanBegan:(UIPanGestureRecognizer *)pan {
    // 修复当从右侧向左滑动时的bug，避免开始的时候从右向左滑动
    CGPoint vel = [pan velocityInView:pan.view];
    if (!self.interacting && vel.x < 0) {
        self.interacting = NO;
        return;
    }
    
    self.interacting = YES;
    self.viewCenter = self.presentVC.view.center;
    if ([self.delegate respondsToSelector:@selector(transitionPanBegan)]) {
        [self.delegate transitionPanBegan];
    }
}

- (void)handlePanChange:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:pan.view.superview];
    CGFloat progress = [self progressForPanGesture:pan];
    CGFloat ratio = 1 - progress * 0.5;
    self.presentVC.view.center = CGPointMake(self.viewCenter.x + translation.x * ratio, self.viewCenter.y + translation.y * ratio);
    self.presentVC.view.transform = CGAffineTransformMakeScale(ratio, ratio);
    [self updateInteractiveTransition:progress];
    if ([self.delegate respondsToSelector:@selector(transitionPanChange)]) {
        [self.delegate transitionPanChange];
    }
}

- (void)handlePanEnded:(UIPanGestureRecognizer *)pan {
    CGFloat progress = [self progressForPanGesture:pan];
    if (progress < 0.2) {
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            self.presentVC.view.center = self.viewCenter;
            self.presentVC.view.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            self.interacting = NO;
            [self cancelInteractiveTransition];
            if ([self.delegate respondsToSelector:@selector(transitionPanEnded:)]) {
                [self.delegate transitionPanEnded:NO];
            }
        }];
    }else {
        self.interacting = NO;
        [self finishInteractiveTransition];
        [self.presentVC dismissViewControllerAnimated:YES completion:nil];
        if ([self.delegate respondsToSelector:@selector(transitionPanEnded:)]) {
            [self.delegate transitionPanEnded:YES];
        }
    }
}

- (CGFloat)progressForPanGesture:(UIPanGestureRecognizer *)pan {
    UIView *superview = pan.view.superview;
    CGPoint translation = [pan translationInView:superview];
    CGFloat progress = translation.x / superview.bounds.size.width;
    progress = fminf(fmaxf(progress, 0.0), 1.0);
    return progress;
}

#pragma mark - UIViewControllerTransitioningDelegate
- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source {
    return [[GKScaleAnimation alloc] initWithType:GKScaleType_Present transition:self];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed {
    return [[GKScaleAnimation alloc] initWithType:GKScaleType_Dismiss transition:self];
}

- (id<UIViewControllerInteractiveTransitioning>)interactionControllerForDismissal:(id<UIViewControllerAnimatedTransitioning>)animator {
    return self.interacting ? self : nil;
}

@end
