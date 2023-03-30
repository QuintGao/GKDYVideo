//
//  GKDYScaleVideoView.h
//  GKDYVideo
//
//  Created by gaokun on 2019/7/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDYUserViewController.h"
#import "GKDYVideoScrollView.h"
#import "GKDYPlayerManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYScaleVideoView : UIView

@property (nonatomic, strong) GKDYVideoScrollView *scrollView;

@property (nonatomic, strong) GKDYPlayerManager *manager;

@property (nonatomic, weak) GKDYUserViewController  *vc;

@property (nonatomic, strong) NSMutableArray *videoList;

@property (nonatomic, assign) NSInteger index;

@property (nonatomic, copy) void(^requestBlock)(void);

- (void)show;
- (void)reloadData;

@end

NS_ASSUME_NONNULL_END
