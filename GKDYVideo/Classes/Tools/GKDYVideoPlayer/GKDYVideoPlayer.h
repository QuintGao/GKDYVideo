//
//  GKDYVideoPlayer.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKDYVideoPlayerStatus) {
    GKDYVideoPlayerStatusUnload,      // 未加载
    GKDYVideoPlayerStatusPrepared,    // 准备播放
    GKDYVideoPlayerStatusLoading,     // 加载中
    GKDYVideoPlayerStatusPlaying,     // 播放中
    GKDYVideoPlayerStatusPaused,      // 暂停
    GKDYVideoPlayerStatusEnded,       // 播放完成
    GKDYVideoPlayerStatusError        // 错误
};

@class GKDYVideoPlayer;

@protocol GKDYVideoPlayerDelegate <NSObject>

- (void)player:(GKDYVideoPlayer *)player statusChanged:(GKDYVideoPlayerStatus)status;

- (void)player:(GKDYVideoPlayer *)player currentTime:(float)currentTime totalTime:(float)totalTime progress:(float)progress;

@end

@interface GKDYVideoPlayer : NSObject

@property (nonatomic, weak) id<GKDYVideoPlayerDelegate>     delegate;

@property (nonatomic, assign) GKDYVideoPlayerStatus         status;

@property (nonatomic, assign) BOOL                          isPlaying;


/**
 根据指定url在指定视图上播放视频
 
 @param playView 播放视图
 @param url 播放地址
 */
- (void)playVideoWithView:(UIView *)playView url:(NSString *)url;

/**
 停止播放并移除播放视图
 */
- (void)removeVideo;

/**
 暂停播放
 */
- (void)pause;

/**
 恢复播放
 */
- (void)resume;

@end

NS_ASSUME_NONNULL_END
