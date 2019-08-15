//
//  GKDYScaleVideoView.h
//  GKDYVideo
//
//  Created by gaokun on 2019/7/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDYPersonalViewController.h"
#import "GKDYVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYScaleVideoView : UIView

@property (nonatomic, strong) GKDYVideoView *videoView;

- (instancetype)initWithVC:(GKDYPersonalViewController *)vc videos:(NSArray *)videos index:(NSInteger)index;

- (void)show;

@end

NS_ASSUME_NONNULL_END
