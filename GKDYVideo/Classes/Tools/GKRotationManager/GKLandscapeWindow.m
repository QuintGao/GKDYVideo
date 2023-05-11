//
//  GKLandscapeWindow.m
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKLandscapeWindow.h"

@implementation GKLandscapeWindow {
    CGRect _old_bounds;
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        self.windowLevel = UIWindowLevelStatusBar - 1;
        if (@available(iOS 13.0, *)) {
            if (self.windowScene == nil) {
                self.windowScene = UIApplication.sharedApplication.keyWindow.windowScene;
            }
            if (self.windowScene == nil) {
                self.windowScene = (UIWindowScene *) UIApplication.sharedApplication.connectedScenes.anyObject;
            }
        }
        self.hidden = YES;
    }
    return self;
}

#ifdef DEBUG
- (void)dealloc {
    NSLog(@"%d \t %s", (int)__LINE__, __func__);
}
#endif

- (void)setRootViewController:(UIViewController *)rootViewController {
    [super setRootViewController:rootViewController];
    rootViewController.view.frame = self.bounds;
    rootViewController.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void)setBackgroundColor:(UIColor *)backgroundColor {}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    return YES;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // 如果是大屏转大屏 就不需要修改了
    if (!CGRectEqualToRect(_old_bounds, self.bounds)) {
        _old_bounds = self.bounds;
        
        UIView *superview = self;
        if (@available(iOS 13.0, *)) {
            superview = self.subviews.firstObject;
        }
        
        [UIView performWithoutAnimation:^{
            for (UIView *view in superview.subviews) {
                if (view != self.rootViewController.view && [view isMemberOfClass:UIView.class]) {
                    view.backgroundColor = UIColor.clearColor;
                    for (UIView *subview in view.subviews) {
                        subview.backgroundColor = UIColor.clearColor;
                    }
                }
            }
        }];
    }
    self.rootViewController.view.frame = self.bounds;
}

@end
