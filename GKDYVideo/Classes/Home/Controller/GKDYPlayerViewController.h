//
//  GKDYPlayerViewController.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYBaseViewController.h"
#import "GKDYVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYPlayerViewController : GKDYBaseViewController

@property (nonatomic, strong) GKDYVideoView *videoView;

// 播放单个视频
- (instancetype)initWithVideoModel:(GKDYVideoModel *)model;

// 播放一组视频，并指定播放位置
- (instancetype)initWithVideos:(NSArray *)videos index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
