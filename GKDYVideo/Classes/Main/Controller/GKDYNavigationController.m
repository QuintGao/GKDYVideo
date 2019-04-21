//
//  GKDYNavigationController.m
//  GKDYVideo
//
//  Created by QuintGao on 2019/4/21.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKDYNavigationController.h"

@interface GKDYNavigationController ()

@end

@implementation GKDYNavigationController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if (self.childViewControllers.count > 0) {
        UIViewController *root = self.childViewControllers[0];
        if (viewController != root) {
            viewController.hidesBottomBarWhenPushed = YES;
        }
    }
    [super pushViewController:viewController animated:animated];
}

@end
