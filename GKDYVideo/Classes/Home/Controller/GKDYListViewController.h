//
//  GKDYListViewController.h
//  GKDYVideo
//
//  Created by gaokun on 2018/12/14.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYBaseViewController.h"
#import <GKPageScrollView/GKPageScrollView.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDYListViewController : GKDYBaseViewController<GKPageListViewDelegate>

- (void)refreshData;

@end

NS_ASSUME_NONNULL_END
