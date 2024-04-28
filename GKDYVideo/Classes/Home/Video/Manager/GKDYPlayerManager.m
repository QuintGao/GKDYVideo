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
#import "GKRotationManager.h"
#import "GKDYVideoPortraitCell.h"
#import "GKDYVideoLandscapeCell.h"
#import "GKDYVideoFullscreenView.h"

@interface GKDYPlayerManager()<GKVideoScrollViewDataSource, GKDYVideoScrollViewDelegate, GKDYVideoPortraitCellDelegate>

@property (nonatomic, strong) ZFPlayerController *player;

@property (nonatomic, strong) GKRotationManager *rotationManager;

@property (nonatomic, assign) BOOL isSeeking;

@property (nonatomic, strong) GKDYVideoFullscreenView *fullscreenView;

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
    
    // 加载状态
    player.playerLoadStateChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, ZFPlayerLoadState loadState) {
        @strongify(self);
        if ((loadState == ZFPlayerLoadStatePrepare || loadState == ZFPlayerLoadStateStalled) && self.player.currentPlayerManager.isPlaying) {
            [self.portraitView.slider showLoading];
        }else {
            [self.portraitView.slider hideLoading];
        }
    };
    
    // 播放时间
    player.playerPlayTimeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, NSTimeInterval currentTime, NSTimeInterval duration) {
        @strongify(self);
        [self.portraitView.slider updateCurrentTime:currentTime totalTime:duration];
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
    
    self.rotationManager = [GKRotationManager rotationManager];
    self.rotationManager.contentView = self.player.currentPlayerManager.view;
    self.landscapeView.rotationManager = self.rotationManager;
    
    // 即将旋转时调用
    self.rotationManager.orientationWillChange = ^(BOOL isFullscreen) {
        @strongify(self);
        self.player.controlView.hidden = YES;
        if (isFullscreen) {
            [self.landscapeView startTimer];
        }else {
            self.player.currentPlayerManager.view.backgroundColor = UIColor.clearColor;
            self.portraitView.hidden = NO;
            [self.landscapeView destoryTimer];
            if (self.landscapeScrollView) {
                UIView *superview = self.landscapeScrollView.superview;
                [superview addSubview:self.rotationManager.contentView];
                [self.landscapeScrollView removeFromSuperview];
                self.landscapeScrollView = nil;
                self.landscapeCell = nil;
            }
        }
    };
    
    // 旋转结束时调用
    self.rotationManager.orientationDidChanged = ^(BOOL isFullscreen) {
        @strongify(self);
        if (isFullscreen) {
//            self.portraitView.hidden = YES;
            self.landscapeView.hidden = NO;
            [self.landscapeView hideContainerView:NO];
            if (!self.landscapeScrollView) {
                [self initLandscapeScrollView];
                UIView *superview = self.rotationManager.contentView.superview;
                self.landscapeScrollView.frame = superview.bounds;
                [superview addSubview:self.landscapeScrollView];
                self.landscapeScrollView.defaultIndex = self.scrollView.currentIndex;
                [self.landscapeScrollView reloadData];
            }
            self.player.controlView = self.landscapeView;
            [self.currentCell resetView];
            [self.landscapeCell hideTopView];
        }else {
            self.portraitView.hidden = NO;
            self.landscapeView.hidden = YES;
            self.player.controlView = self.portraitView;
            if (self.player.containerView != self.currentCell.coverImgView) {
                self.player.containerView = self.currentCell.coverImgView;
            }
            self.player.currentPlayerManager.view.backgroundColor = UIColor.blackColor;
        }
    };
    
    player.presentationSizeChanged = ^(id<ZFPlayerMediaPlayback>  _Nonnull asset, CGSize size) {
        @strongify(self);
        self.videoSize = size;
    };
}

- (void)initLandscapeScrollView {
    self.landscapeScrollView = [[GKDYVideoScrollView alloc] init];
    self.landscapeScrollView.backgroundColor = UIColor.blackColor;
    self.landscapeScrollView.dataSource = self;
    self.landscapeScrollView.delegate = self;
    [self.landscapeScrollView registerClass:GKDYVideoLandscapeCell.class forCellReuseIdentifier:@"GKDYVideoLandscapeCell"];
}

- (BOOL)isPlaying {
    return self.player.currentPlayerManager.isPlaying;
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
    if (self.dataSources.count - index < 2) {
        if ([self.delegate respondsToSelector:@selector(scrollViewShouldLoadMore)]) {
            [self.delegate scrollViewShouldLoadMore];
        }
    }
    
    GKDYVideoModel *model = self.dataSources[index];
    
    self.landscapeView.model = model;
    
    if ([cell isKindOfClass:GKDYVideoPortraitCell.class]) {
        self.currentCell = (GKDYVideoPortraitCell *)cell;
        self.portraitView = self.currentCell.portraitView;
        self.rotationManager.containerView = cell.coverImgView;
        if (self.rotationManager.isFullscreen) return;
    }else {
        self.landscapeCell = (GKDYVideoLandscapeCell *)cell;
        [self.landscapeCell autoHide];
        [self.scrollView scrollToPageWithIndex:index];
    }
    
    // 设置播放内容视图
    if (self.player.containerView != cell.coverImgView) {
        self.player.containerView = cell.coverImgView;
    }
    
    // 设置播放器控制层视图
    if ([cell isKindOfClass:GKDYVideoPortraitCell.class]) {
        GKDYVideoPortraitCell *portraitCell = (GKDYVideoPortraitCell *)cell;
        if (self.player.controlView != portraitCell.portraitView) {
            self.player.controlView = portraitCell.portraitView;
            self.portraitView = portraitCell.portraitView;
        }
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
    if ([self.player.controlView isKindOfClass:GKDYVideoPortraitView.class]) {
        [self.player.controlView removeFromSuperview];
        self.player.controlView = nil;
    }
    [cell resetView];
}

- (void)rotate {
    [self.rotationManager rotate];
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
    [self.scrollView reloadData];
//    [self.currentCell showLikeAnimation];
}

#pragma mark - GKVideoScrollViewDataSource
- (NSInteger)numberOfRowsInScrollView:(GKVideoScrollView *)scrollView {
    return self.dataSources.count;
}

- (GKVideoViewCell *)scrollView:(GKVideoScrollView *)scrollView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKDYVideoModel *model = self.dataSources[indexPath.row];
    if (scrollView == self.scrollView) {
        GKDYVideoPortraitCell *cell = [scrollView dequeueReusableCellWithIdentifier:@"GKDYVideoPortraitCell" forIndexPath:indexPath];
        cell.delegate = self;
        cell.manager = self;
        cell.portraitView.slider.player = self.player;
        [cell loadData:model];
        return cell;
    }else {
        GKDYVideoLandscapeCell *cell = [scrollView dequeueReusableCellWithIdentifier:@"GKDYVideoLandscapeCell" forIndexPath:indexPath];
        [cell loadData:model];
        @weakify(self);
        cell.backClickBlock = ^{
            @strongify(self);
            [self rotate];
        };
        [cell showTopView];
        return cell;
    }
}

#pragma mark - GKDYVideoScrollViewDelegate
- (void)scrollView:(GKVideoScrollView *)scrollView didEndScrollingCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self playVideoWithCell:(GKDYVideoCell *)cell index:indexPath.row];
}

- (void)scrollView:(GKVideoScrollView *)scrollView didEndDisplayingCell:(GKVideoViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    [self stopPlayWithCell:(GKDYVideoCell *)cell index:indexPath.row];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self.scrollView) {
        if (self.scrollView.currentIndex == 0 && scrollView.contentOffset.y < 0) {
            self.scrollView.contentOffset = CGPointZero;
        }
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.portraitView willBeginDragging];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self.portraitView didEndDragging];
}

- (void)scrollView:(GKDYVideoScrollView *)scrollView didPanWithDistance:(CGFloat)distance isEnd:(BOOL)isEnd {
    if ([self.delegate respondsToSelector:@selector(scrollViewDidPanDistance:isEnd:)]) {
        [self.delegate scrollViewDidPanDistance:distance isEnd:isEnd];
    }
}

#pragma mark - GKDYVideoPortraitCellDelegate
- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickIcon:(GKDYVideoModel *)model {
    if ([self.delegate respondsToSelector:@selector(cellDidClickIcon:)]) {
        [self.delegate cellDidClickIcon:model];
    }
}

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickLike:(GKDYVideoModel *)model {
    [self.scrollView reloadData];
}

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickComment:(GKDYVideoModel *)model {
    if ([self.delegate respondsToSelector:@selector(cellDidClickComment:cell:)]) {
        [self.delegate cellDidClickComment:model cell:cell];
    }
}

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickShare:(GKDYVideoModel *)model {
    
}

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickDanmu:(GKDYVideoModel *)model {
    
}

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickFullscreen:(GKDYVideoModel *)model {
    [self rotate];
}

- (void)videoCell:(GKDYVideoPortraitCell *)cell zoomBegan:(GKDYVideoModel *)model {
    self.player.controlView.hidden = YES;
    if ([self.delegate respondsToSelector:@selector(cellZoomBegan:)]) {
        [self.delegate cellZoomBegan:model];
    }
}

- (void)videoCell:(GKDYVideoPortraitCell *)cell zoomEnded:(GKDYVideoModel *)model isFullscreen:(BOOL)isFullscreen {
    if (isFullscreen) {
        self.fullscreenView.hidden = NO;
        if (self.player.controlView != self.fullscreenView) {
            self.player.controlView = self.fullscreenView;
            self.player.disableGestureTypes = ZFPlayerDisableGestureTypesPinch;
        }
    }else {
        self.currentCell.portraitView.hidden = NO;
        if (self.player.controlView != self.currentCell.portraitView) {
            self.player.controlView = self.currentCell.portraitView;
            self.player.disableGestureTypes = ZFPlayerDisableGestureTypesPan | ZFPlayerDisableGestureTypesPinch;
        }
    }
    if ([self.delegate respondsToSelector:@selector(cellZoomEnded:isFullscreen:)]) {
        [self.delegate cellZoomEnded:model isFullscreen:isFullscreen];
    }
}

#pragma mark - Lazy
- (GKDYVideoScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[GKDYVideoScrollView alloc] init];
        _scrollView.dataSource = self;
        _scrollView.delegate = self;
        _scrollView.backgroundColor = UIColor.blackColor;
        [_scrollView registerClass:GKDYVideoPortraitCell.class forCellReuseIdentifier:@"GKDYVideoPortraitCell"];
        [_scrollView addPanGesture];
    }
    return _scrollView;
}

- (GKDYVideoLandscapeView *)landscapeView {
    if (!_landscapeView) {
        _landscapeView = [[GKDYVideoLandscapeView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        
        @weakify(self);
        _landscapeView.likeBlock = ^(GKDYVideoModel * _Nonnull model) {
            @strongify(self);
            [self likeVideoWithModel:model];
        };
        
        _landscapeView.singleTapBlock = ^{
            @strongify(self);
            if (self.landscapeCell.isShowTop) {
                [self.landscapeCell hideTopView];
                [self.landscapeView hideContainerView:NO];
            }else {
                [self.landscapeView autoHide];
            }
        };
    }
    return _landscapeView;
}

- (GKDYVideoFullscreenView *)fullscreenView {
    if (!_fullscreenView) {
        _fullscreenView = [[GKDYVideoFullscreenView alloc] init];
        
        @weakify(self);
        _fullscreenView.closeFullscreenBlock = ^{
            @strongify(self);
            [self.currentCell closeFullscreen];
        };
        
        _fullscreenView.likeBlock = ^{
            @strongify(self);
            [self likeVideoWithModel:nil];
        };
    }
    return _fullscreenView;
}

- (NSMutableArray *)dataSources {
    if (!_dataSources) {
        _dataSources = [NSMutableArray array];
    }
    return _dataSources;
}

@end
