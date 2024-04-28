//
//  GKDYPlayerManager.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKDYVideoScrollView.h"
#import "GKDYVideoPortraitView.h"
#import "GKDYVideoLandscapeView.h"
#import "GKDYPlayerViewController.h"
#import <ZFPlayer/ZFPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@class GKDYVideoCell, GKDYVideoPortraitCell, GKDYVideoLandscapeCell;

@protocol GKDYPlayerManagerDelegate <NSObject>

- (void)scrollViewShouldLoadMore;

- (void)scrollViewDidPanDistance:(CGFloat)distance isEnd:(BOOL)isEnd;

- (void)cellDidClickIcon:(GKDYVideoModel *)model;

- (void)cellDidClickComment:(GKDYVideoModel *)model cell:(GKDYVideoPortraitCell *)cell;

- (void)cellZoomBegan:(GKDYVideoModel *)model;

- (void)cellZoomEnded:(GKDYVideoModel *)model isFullscreen:(BOOL)isFullscreen;

@end

@interface GKDYPlayerManager : NSObject

@property (nonatomic, strong, readonly) ZFPlayerController *player;

@property (nonatomic, weak) id<GKDYPlayerManagerDelegate> delegate;

// 竖屏滑动容器
@property (nonatomic, strong) GKDYVideoScrollView *scrollView;

// 横屏滑动容器
@property (nonatomic, strong, nullable) GKDYVideoScrollView *landscapeScrollView;

@property (nonatomic, weak) GKDYVideoPortraitCell *currentCell;

@property (nonatomic, weak) GKDYVideoLandscapeCell *landscapeCell;

// 竖屏控制层
@property (nonatomic, weak) GKDYVideoPortraitView *portraitView;

// 横屏控制层
@property (nonatomic, strong) GKDYVideoLandscapeView *landscapeView;

@property (nonatomic, assign) CGSize videoSize;

/// 页码
@property (nonatomic, assign) NSInteger page;

/// 数据源
@property (nonatomic, strong) NSMutableArray *dataSources;

@property (nonatomic, assign) BOOL isPlaying;

@property (nonatomic, assign) BOOL isAppeared;

/// 请求播放地址
- (void)requestPlayUrlWithModel:(GKDYVideoModel *)model completion:(nullable void(^)(void))completion;

/// 播放视频
- (void)playVideoWithCell:(GKDYVideoCell *)cell index:(NSInteger)index;

/// 停止播放
- (void)stopPlayWithCell:(GKDYVideoCell *)cell index:(NSInteger)index;

/// 旋转
- (void)rotate;

- (void)play;
- (void)pause;

@end

NS_ASSUME_NONNULL_END
