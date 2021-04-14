//
//  GKDYPersonalViewController.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/24.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYBaseViewController.h"
#import "GKAWEModel.h"
#import "GKDYListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYPersonalViewController : GKDYBaseViewController

@property (nonatomic, strong) GKAWEModel            *model;

// 当前显示的控制器
@property (nonatomic, strong) GKDYListViewController    *currentListVC;

@end

NS_ASSUME_NONNULL_END
