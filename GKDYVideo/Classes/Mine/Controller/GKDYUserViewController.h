//
//  GKDYUserViewController.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYBaseViewController.h"
#import "GKDYVideoModel.h"
#import "GKDYVideoListViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYUserViewController : GKDYBaseViewController

@property (nonatomic, strong) GKDYVideoModel *model;

@property (nonatomic, weak) GKDYVideoListViewController *currentListVC;

@end

NS_ASSUME_NONNULL_END
