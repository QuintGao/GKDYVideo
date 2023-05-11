//
//  GKLandscapeViewController.h
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@protocol GKLandscapeViewControllerDelegate;

@interface GKLandscapeViewController : UIViewController

@property (nonatomic, weak, nullable) id<GKLandscapeViewControllerDelegate> delegate;

@property (nonatomic, assign) BOOL disableAnimations;

@property (nonatomic, assign) BOOL statusBarHidden;

@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;

@property (nonatomic, assign) UIStatusBarAnimation statusBarAnimation;

@end

@protocol GKLandscapeViewControllerDelegate <NSObject>

@optional
- (BOOL)viewControllerShouldAutorotate:(GKLandscapeViewController *)viewController;
- (void)viewController:(GKLandscapeViewController *)viewController viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator;

@end

NS_ASSUME_NONNULL_END
