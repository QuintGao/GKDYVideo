//
//  GKDYPlayerManager.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GKVideoScrollView/GKVideoScrollView.h>
#import "GKDYVideoPortraitView.h"
#import "GKDYVideoLandscapeView.h"

NS_ASSUME_NONNULL_BEGIN

@class GKDYVideoCell;

@interface GKDYPlayerManager : NSObject

@property (nonatomic, weak) GKVideoScrollView *scrollView;

@property (nonatomic, weak) GKDYVideoCell *currentCell;

// 竖屏控制层
@property (nonatomic, strong) GKDYVideoPortraitView *portraitView;

// 横屏控制层
@property (nonatomic, strong) GKDYVideoLandscapeView *landscapeView;

/// 页码
@property (nonatomic, assign) NSInteger page;

/// 数据源
@property (nonatomic, strong) NSMutableArray *dataSources;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) BOOL isAppeared;

/// 请求数据
- (void)requestDataWithTab:(NSString *)tab completion:(nullable void(^)(void))completion;

/// 请求播放地址
- (void)requestPlayUrlWithModel:(GKDYVideoModel *)model completion:(nullable void(^)(void))completion;

/// 播放视频
- (void)playVideoWithCell:(GKDYVideoCell *)cell index:(NSInteger)index;

/// 停止播放
- (void)stopPlayWithCell:(GKDYVideoCell *)cell index:(NSInteger)index;

/// 进入全屏
- (void)enterFullscreen;

- (void)play;
- (void)pause;

@end

NS_ASSUME_NONNULL_END
