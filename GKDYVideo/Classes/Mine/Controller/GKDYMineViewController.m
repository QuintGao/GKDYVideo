//
//  GKDYMineViewController.m
//  GKDYVideo
//
//  Created by gaokun on 2019/5/8.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKDYMineViewController.h"

@interface GKDYMineViewController ()

@end

@implementation GKDYMineViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navBackgroundColor = [UIColor clearColor];
    self.gk_navShadowColor = [UIColor colorWithWhite:1.0f alpha:0.2f];
    self.gk_navTitle = @"我";
    
    self.view.backgroundColor = [UIColor blackColor];
}

@end
