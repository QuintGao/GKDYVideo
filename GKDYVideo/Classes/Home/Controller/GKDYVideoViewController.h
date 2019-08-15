//
//  GKDYVideoViewController.h
//  GKDYVideo
//
//  Created by gaokun on 2019/7/3.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKDYBaseViewController.h"
#import "GKDYVideoView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoViewController : GKDYBaseViewController

@property (nonatomic, strong) GKDYVideoView *videoView;


/**
 初始化播放器，播放一组视频并设置播放位置

 @param videos 视频数组
 @param index 视频索引
 @return 播放器对象
 */
- (instancetype)initWithVideos:(NSArray *)videos index:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
