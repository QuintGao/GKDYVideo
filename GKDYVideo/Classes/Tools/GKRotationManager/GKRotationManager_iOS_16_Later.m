//
//  GKRotationManager_iOS_16_Later.m
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKRotationManager_iOS_16_Later.h"
#import "GKLandscapeViewController.h"

@interface GKRotationManager_iOS_16_Later()

@property (nonatomic, strong, readonly) GKLandscapeViewController *landscapeViewController;

@end

@implementation GKRotationManager_iOS_16_Later
@synthesize landscapeViewController = _landscapeViewController;
- (__kindof GKLandscapeViewController *)landscapeViewController {
    if (!_landscapeViewController) {
        _landscapeViewController = [[GKLandscapeViewController alloc] init];
    }
    return _landscapeViewController;
}

- (void)setNeedsUpdateOfSupportedInterfaceOrientations {
    if (@available(iOS 16.0, *)) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 160000
        [UIApplication.sharedApplication.keyWindow.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
        [self.window.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
#else
        [(id)UIApplication.sharedApplication.keyWindow.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
        [(id)self.window.rootViewController setNeedsUpdateOfSupportedInterfaceOrientations];
#endif
    }
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation completion:(void (^)(void))completion {
    [super interfaceOrientation:orientation completion:completion];
    UIInterfaceOrientation fromOrientation = [self getCurrentOrientation];
    UIInterfaceOrientation toOrientation = orientation;
    [self willChangeOrientation:toOrientation];
    self.currentOrientation = toOrientation;
    
    UIWindow *sourceWindow = self.containerView.window;
    CGRect sourceFrame = [self.containerView convertRect:self.containerView.bounds toView:sourceWindow];
    CGRect screenBounds = UIScreen.mainScreen.bounds;
    CGFloat maxSize = MAX(screenBounds.size.width, screenBounds.size.height);
    CGFloat minSize = MIN(screenBounds.size.width, screenBounds.size.height);
    
    self.contentView.autoresizingMask = UIViewAutoresizingNone;
    if (fromOrientation == UIInterfaceOrientationPortrait || self.contentView.superview != self.landscapeViewController.view) {
        self.contentView.frame = sourceFrame;
        [sourceWindow addSubview:self.contentView];
        [self.contentView layoutIfNeeded];
        [UIView performWithoutAnimation:^{
            if (!self.window.isKeyWindow) {
                self.window.hidden = NO;
                [self.window makeKeyAndVisible];
            }
        }];
    }else if (toOrientation == UIInterfaceOrientationPortrait) {
        self.contentView.bounds = CGRectMake(0, 0, maxSize, minSize);
        self.contentView.center = CGPointMake(minSize * 0.5, maxSize * 0.5);
        self.contentView.transform = [self getRotationTransform:fromOrientation];
        [sourceWindow addSubview:self.contentView];
        [UIView performWithoutAnimation:^{
            [sourceWindow makeKeyAndVisible];
            [self.contentView layoutIfNeeded];
            self.window.hidden = YES;
            [self.window resignKeyWindow];
            self.window = nil;
        }];
    }
    [self setNeedsUpdateOfSupportedInterfaceOrientations];
    
    CGRect rotationBounds = CGRectZero;
    CGPoint rotationCenter = CGPointZero;
    if (UIInterfaceOrientationIsLandscape(toOrientation)) {
        rotationBounds = CGRectMake(0, 0, maxSize, minSize);
        rotationCenter = (fromOrientation == UIInterfaceOrientationPortrait || self.contentView.superview != self.landscapeViewController.view) ? CGPointMake(minSize * 0.5, maxSize * 0.5) : CGPointMake(maxSize * 0.5, minSize * 0.5);
    }
    
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    if (fromOrientation == UIInterfaceOrientationPortrait) {
        rotationTransform = [self getRotationTransform:toOrientation];
    }
    
    if (self.disableAnimations) {
        [CATransaction begin];
        [CATransaction setDisableActions:YES];
    }
    [UIView animateWithDuration:0.3 animations:^{
        if (toOrientation == UIInterfaceOrientationPortrait) {
            self.contentView.transform = rotationTransform;
            self.contentView.frame = sourceFrame;
        }else {
            self.contentView.transform = rotationTransform;
            self.contentView.bounds = rotationBounds;
            self.contentView.center = rotationCenter;
        }
        [self.contentView layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (self.disableAnimations) {
            [CATransaction commit];
        }
        self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        if (toOrientation == UIInterfaceOrientationPortrait) {
            [self.containerView addSubview:self.contentView];
            self.contentView.frame = self.containerView.bounds;
        }else {
            [self setNeedsUpdateOfSupportedInterfaceOrientations];
            self.contentView.transform = CGAffineTransformIdentity;
            [self.landscapeViewController.view addSubview:self.contentView];
            self.contentView.frame = self.window.bounds;
            [self.contentView layoutIfNeeded];
        }
        !completion ?: completion();
        [self didChangeOrientation:toOrientation];
    }];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    if (window == self.window) {
        return 1 << self.currentOrientation;
    }
    return UIInterfaceOrientationMaskPortrait;
}

- (CGAffineTransform)getRotationTransform:(UIInterfaceOrientation)orientation {
    CGAffineTransform rotationTransform = CGAffineTransformIdentity;
    if (orientation == UIInterfaceOrientationLandscapeLeft) {
        rotationTransform = CGAffineTransformMakeRotation(-M_PI_2);
    } else if (orientation == UIInterfaceOrientationLandscapeRight) {
        rotationTransform = CGAffineTransformMakeRotation(M_PI_2);
    }
    return rotationTransform;
}

@end
