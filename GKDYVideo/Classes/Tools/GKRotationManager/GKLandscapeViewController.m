//
//  GKLandscapeViewController.m
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKLandscapeViewController.h"

@implementation GKLandscapeViewController

- (instancetype)init {
    if (self = [super init]) {
        _statusBarStyle = UIStatusBarStyleLightContent;
        _statusBarAnimation = UIStatusBarAnimationSlide;
    }
    return self;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    if ([self.delegate respondsToSelector:@selector(viewController:viewWillTransitionToSize:withTransitionCoordinator:)]) {
        [self.delegate viewController:self viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    }
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAllButUpsideDown;
}

- (BOOL)prefersHomeIndicatorAutoHidden {
    return YES;
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return self.statusBarHidden;
}

- (BOOL)prefersStatusBarHidden {
    return self.statusBarStyle;
}

- (UIStatusBarAnimation)preferredStatusBarUpdateAnimation {
    return self.statusBarAnimation;
}

@end
