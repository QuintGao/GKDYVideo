//
//  GKRotationManager_iOS_9_15.m
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKRotationManager_iOS_9_15.h"
#import "GKLandscapeViewController.h"

API_DEPRECATED("deprecated!", ios(9.0, 16.0)) @interface GKLandscapeViewController_iOS_9_15 : GKLandscapeViewController
@property (nonatomic, strong, readonly) UIView *playerSuperview;
@end

@implementation GKLandscapeViewController_iOS_9_15

- (void)viewDidLoad {
    [super viewDidLoad];
    _playerSuperview = [[UIView alloc] initWithFrame:CGRectZero];
    _playerSuperview.backgroundColor = UIColor.clearColor;
    [self.view addSubview:_playerSuperview];
}

- (BOOL)shouldAutorotate {
    if ([self.delegate respondsToSelector:@selector(viewControllerShouldAutorotate:)]) {
        return [self.delegate viewControllerShouldAutorotate:self];
    }
    return NO;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end

@interface GKRotationManager_iOS_9_15()<GKLandscapeViewControllerDelegate> {
    void(^_rotateCompleted)(void);
}

@property (nonatomic, strong, readonly) GKLandscapeViewController_iOS_9_15 *landscapeViewController;

@property (nonatomic, assign) BOOL forceRotation;

@end

@implementation GKRotationManager_iOS_9_15

@synthesize landscapeViewController = _landscapeViewController;
- (GKLandscapeViewController *)landscapeViewController {
    if (!_landscapeViewController) {
        _landscapeViewController = [[GKLandscapeViewController_iOS_9_15 alloc] init];
        _landscapeViewController.delegate = self;
    }
    return _landscapeViewController;
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation completion:(void (^)(void))completion {
    [super interfaceOrientation:orientation completion:completion];
    _rotateCompleted = completion;
    self.forceRotation = YES;
    [UIDevice.currentDevice setValue:@(UIDeviceOrientationUnknown) forKey:@"orientation"];
    [UIDevice.currentDevice setValue:@(orientation) forKey:@"orientation"];
}

- (void)rotationBegin {
    if (self.window.isHidden) {
        self.window.hidden = NO;
        [self.window makeKeyAndVisible];
    }
    [UIView animateWithDuration:0.0 animations:^{} completion:^(BOOL finished) {
        [self.window.rootViewController setNeedsStatusBarAppearanceUpdate];
    }];
}

- (void)rotationEnd {
    if (!self.window.isHidden && !UIInterfaceOrientationIsLandscape(self.currentOrientation)) {
        self.window.hidden = YES;
        [self.containerView.window makeKeyAndVisible];
    }
    self.disableAnimations = NO;
    if (_rotateCompleted) {
        _rotateCompleted();
        _rotateCompleted = nil;
    }
}

- (BOOL)allowsRotation {
    if (UIDeviceOrientationIsValidInterfaceOrientation(UIDevice.currentDevice.orientation)) {
        UIInterfaceOrientation toOrientation = self.currentDeviceOrientation;
        if (![self isSupportInterfaceOrientation:toOrientation]) {
            return NO;
        }
    }
    if (self.forceRotation) return YES;
    if (self.allowOrientationRotation) return YES;
    return NO;
}

#pragma mark - GKLandscapeViewControllerDelegate
- (BOOL)viewControllerShouldAutorotate:(GKLandscapeViewController *)viewController {
    if ([self allowsRotation]) {
        [self rotationBegin];
        return YES;
    }
    return NO;
}

- (void)viewController:(GKLandscapeViewController *)viewController viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    UIInterfaceOrientation toOrientation = self.currentDeviceOrientation;
    if (![self isSupportInterfaceOrientation:toOrientation]) return;
    [self willChangeOrientation:toOrientation];
    self.currentOrientation = toOrientation;
    if (self.currentOrientation != UIInterfaceOrientationPortrait) {
        if (self.contentView.superview != self.landscapeViewController.playerSuperview) {
            CGRect frame = [self.contentView convertRect:self.contentView.bounds toView:self.contentView.window];
            self.landscapeViewController.playerSuperview.frame = frame;
            self.contentView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
            self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            [self.landscapeViewController.playerSuperview addSubview:self.contentView];
            [self.contentView layoutIfNeeded];
        }
        if (self.disableAnimations) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
        }
        [UIView animateWithDuration:0.0 animations:^{ /** preparing */} completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self.landscapeViewController.playerSuperview.frame = (CGRect){CGPointZero, size};
                [self.contentView layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (self.disableAnimations) {
                    [CATransaction commit];
                }
                self.forceRotation = NO;
                [self rotationEnd];
                [self didChangeOrientation:toOrientation];
            }];
        }];
    }else {
        if (self.disableAnimations) {
            [CATransaction begin];
            [CATransaction setDisableActions:YES];
        }
        [UIView animateWithDuration:0.0 animations:^{ /** preparing */ } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 animations:^{
                self.landscapeViewController.playerSuperview.frame = [self.containerView convertRect:self.containerView.bounds toView:self.containerView.window];
                [self.contentView layoutIfNeeded];
            } completion:^(BOOL finished) {
                if (self.disableAnimations) {
                    [CATransaction commit];
                }
                self.forceRotation = NO;
                UIView *snapshot = [self.contentView snapshotViewAfterScreenUpdates:NO];
                snapshot.frame = self.containerView.bounds;
                snapshot.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                [self.containerView addSubview:snapshot];
                [UIView animateWithDuration:0.0 animations:^{} completion:^(BOOL finished) {
                    self.contentView.frame = self.containerView.bounds;
                    self.contentView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
                    [self.containerView addSubview:self.contentView];
                    [self.contentView layoutIfNeeded];
                    [snapshot removeFromSuperview];
                    [self rotationEnd];
                    [self didChangeOrientation:toOrientation];
                }];
            }];
        }];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

@end
