//
//  GKDYPlayerManager.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYPlayerManager.h"
#import <AFNetworking/AFNetworking.h>
#import <ZFPlayer/ZFPlayer.h>
#import <ZFPlayer/ZFAVPlayerManager.h>
#import "GKDYVideoCell.h"

@interface GKDYPlayerManager()

@property (nonatomic, strong) ZFPlayerController *player;

@property (nonatomic, assign) BOOL isSeeking;

@end

@implementation GKDYPlayerManager

- (instancetype)init {
    if (self = [super init]) {
        [self initPlayer];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"GKDYPlayerManager dealloc");
    [self stop];
}

- (void)initPlayer {
    // 初始化播放器
    ZFAVPlayerManager *manager = [[ZFAVPlayerManager alloc] init];
    manager.shouldAutoPlay = NO; // 自动播放
    
    ZFPlayerController *player = [[ZFPlayerController alloc] init];
    player.currentPlayerManager = manager;
    player.disableGestureTypes = ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
    player.allowOrentitaionRotation = NO; // 禁止自动旋转
    player.controlView = self.portraitView; // 设置竖屏控制层
    self.player = player;
    
    @weakify(self);
    // 播放结束回调
    player.playerDidToEnd = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset) {
        @strongify(self);
        [self.player.currentPlayerManager replay];
    };
    
    // 播放失败回调
    player.playerPlayFailed = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, id  _Nonnull error) {
        @strongify(self);
        self.portraitView.playBtn.hidden = NO;
    };
    
    // 加载状态改变
    player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        @strongify(self);
        if ((loadState == ZFPlayerLoadStatePrepare || loadState == ZFPlayerLoadStateStalled) && self.player.currentPlayerManager.isPlaying) {
            [self.currentCell.slider showLoading];
        }else {
            [self.currentCell.slider hideLoading];
        }
    };
    
    // 播放状态改变
    player.playerPlayStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerPlaybackState playState) {
        @strongify(self);
        if (playState == ZFPlayerPlayStatePaused) {
            [self.currentCell showLargeSlider];
//            self.portraitView.playBtn.hidden = NO;
        }else {
            [self.currentCell showSmallSlider];
//            self.portraitView.playBtn.hidden = YES;
        }
    };
    
    // 播放进度改变
    player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        @strongify(self);
        if (self.isSeeking) return;
        [self.currentCell.slider updateCurrentTime:currentTime totalTime:duration];
    };
    
    // 方向即将改变
    player.orientationWillChange = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self);
        self.player.controlView.hidden = YES;
        if (player.isFullScreen) {
            [self.landscapeView startTimer];
        }else {
            [self.landscapeView destoryTimer];
        }
    };
    
    // 方向已经改变
    player.orientationDidChanged = ^(ZFPlayerController * _Nonnull player, BOOL isFullScreen) {
        @strongify(self);
        if (isFullScreen) {
            self.landscapeView.hidden = NO;
            self.player.controlView = self.landscapeView;
        }else {
            self.portraitView.hidden = NO;
            self.player.controlView = self.portraitView;
        }
    };
}

- (BOOL)isPlaying {
    return self.player.currentPlayerManager.isPlaying;
}

- (void)requestDataWithTab:(NSString *)tab completion:(void (^)(void))completion {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    // 好看视频 num=5，每次请求5条
    NSString *url = [NSString stringWithFormat:@"https://haokan.baidu.com/web/video/feed?tab=%@&act=pcFeed&pd=pc&num=%d", tab, 5];
    
    @weakify(self);
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        if ([responseObject[@"errno"] integerValue] == 0) {
            NSArray *videos = responseObject[@"data"][@"response"][@"videos"];
            
            if (self.page == 1) {
                [self.dataSources removeAllObjects];
            }
            
            [videos enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                GKDYVideoModel *model = [GKDYVideoModel yy_modelWithDictionary:obj];
                [self.dataSources addObject:model];
            }];
            
            [self.scrollView.mj_footer endRefreshing];
            
            if (self.page >= 10) { // 最多10页
                [self.scrollView.mj_footer endRefreshingWithNoMoreData];
            }
            [self.scrollView reloadData];
        }
        !completion ?: completion();
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        @strongify(self);
        [self.scrollView.mj_footer endRefreshing];
        !completion ?: completion();
    }];
}

- (void)requestPlayUrlWithModel:(GKDYVideoModel *)model completion:(nullable void (^)(void))completion {
    if (model.play_url.length > 0) return;
    
    if (model.task) {
        [model.task cancel];
        model.task = nil;
    }
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *url = [NSString stringWithFormat:@"https://haokan.baidu.com/v?vid=%@&_format=json&", model.video_id];
    
    model.task = [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"errno"] integerValue] == 0) {
            NSDictionary *videoMeta = responseObject[@"data"][@"apiData"][@"curVideoMeta"];
            model.play_url = videoMeta[@"playurl"];
            model.comment = videoMeta[@"comment"];
            model.like = videoMeta[@"fmlike_num"];
            
            __block NSInteger index = 0;
            __block BOOL exist = NO;
            [self.dataSources enumerateObjectsUsingBlock:^(GKDYVideoModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
                if ([obj.video_id isEqualToString:model.video_id]) {
                    index = idx;
                    exist = YES;
                    *stop = YES;
                }
            }];
            [self.dataSources replaceObjectAtIndex:index withObject:model];
            model.task = nil;
            !completion ?: completion();
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        model.task = nil;
        NSLog(@"播放地址请求失败");
    }];
}

- (void)playVideoWithCell:(GKDYVideoCell *)cell index:(NSInteger)index {
    GKDYVideoModel *model = self.dataSources[index];
    
    // 记录cell
    self.currentCell = cell;
    self.landscapeView.model = model;
    if (!self.currentCell.slider.player) {
        self.currentCell.slider.player = self.player;
    }
    
    // 设置播放内容视图
    if (self.player.containerView != cell.coverImgView) {
        self.player.containerView = cell.coverImgView;
    }
    
    // 设置封面图片
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    [manager.view.coverImageView sd_setImageWithURL:[NSURL URLWithString:model.poster_small]];
    
    if (model.play_url.length > 0) {
        // 播放内容一致，不做处理
        if ([self.player.assetURL.absoluteString isEqualToString:model.play_url]) return;
        
        // 设置播放地址
        self.player.assetURL = [NSURL URLWithString:model.play_url];
        self.portraitView.playBtn.hidden = YES;
        if (self.isAppeared) {
            [self.player.currentPlayerManager play];
        }
    }else {
        @weakify(self);
        [self requestPlayUrlWithModel:model completion:^{
            @strongify(self);
            // 播放内容一致，不做处理
            if ([self.player.assetURL.absoluteString isEqualToString:model.play_url]) return;
            
            // 设置播放地址
            self.player.assetURL = [NSURL URLWithString:model.play_url];
            self.portraitView.playBtn.hidden = YES;
            if (self.isAppeared) {
                [self.player.currentPlayerManager play];
            }
        }];
    }
}

- (void)stopPlayWithCell:(GKDYVideoCell *)cell index:(NSInteger)index {
    GKDYVideoModel *model = self.dataSources[index];
    if (![self.player.assetURL.absoluteString isEqualToString:model.play_url]) return;
    
    [self.player stop];
    [self.currentCell resetView];
}

- (void)enterFullscreen {
    [self.player enterFullScreen:YES animated:YES];
}

- (void)play {
    if (self.isPlaying) return;
    [self.player.currentPlayerManager play];
}

- (void)pause {
    if (!self.isPlaying) return;
    [self.player.currentPlayerManager pause];
}

- (void)stop {
    [self.player.currentPlayerManager stop];
    self.player = nil;
}

#pragma mark - Private
- (void)likeVideoWithModel:(GKDYVideoModel *)model {
    if (model == nil) {
        model = self.currentCell.model;
    }
    model.isLike = YES;
    [self.currentCell showLikeAnimation];
}

#pragma mark - Lazy
- (GKDYVideoPortraitView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[GKDYVideoPortraitView alloc] init];
        
        @weakify(self);
        _portraitView.likeBlock = ^{
            @strongify(self);
            [self likeVideoWithModel:nil];
        };
    }
    return _portraitView;
}

- (GKDYVideoLandscapeView *)landscapeView {
    if (!_landscapeView) {
        _landscapeView = [[GKDYVideoLandscapeView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        @weakify(self);
        _landscapeView.likeBlock = ^(GKDYVideoModel * _Nonnull model) {
            @strongify(self);
            [self likeVideoWithModel:model];
        };
    }
    return _landscapeView;
}

- (NSMutableArray *)dataSources {
    if (!_dataSources) {
        _dataSources = [NSMutableArray array];
    }
    return _dataSources;
}

@end
