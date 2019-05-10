//
//  GKDYVideoView.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYVideoView.h"
#import "GKDYVideoPlayer.h"

@interface GKDYVideoView()<UIScrollViewDelegate, GKDYVideoPlayerDelegate, GKDYVideoControlViewDelegate, UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIScrollView              *scrollView;

// 创建三个控制视图，用于滑动切换
@property (nonatomic, strong) GKDYVideoControlView      *topView;   // 顶部视图
@property (nonatomic, strong) GKDYVideoControlView      *ctrView;   // 中间视图
@property (nonatomic, strong) GKDYVideoControlView      *btmView;   // 底部视图

// 控制播放的索引，不完全等于当前播放内容的索引
@property (nonatomic, assign) NSInteger                 index;

// 当前播放内容是h索引
@property (nonatomic, assign) NSInteger                 currentPlayIndex;

@property (nonatomic, weak) UIViewController            *vc;
@property (nonatomic, assign) BOOL                      isPushed;

@property (nonatomic, strong) NSMutableArray            *videos;

@property (nonatomic, strong) GKDYVideoPlayer           *player;

// 记录播放内容
@property (nonatomic, copy) NSString                    *currentPlayId;

// 记录滑动前的播放状态
@property (nonatomic, assign) BOOL                      isPlaying_beforeScroll;

@property (nonatomic, assign) BOOL                      isRefreshMore;

@property (nonatomic, strong) UIPanGestureRecognizer    *panGesture;
// 开始移动时的位置
@property (nonatomic, assign) CGFloat                   startLocationY;

@end

@implementation GKDYVideoView

- (instancetype)initWithVC:(UIViewController *)vc isPushed:(BOOL)isPushed {
    if (self = [super init]) {
        self.vc = vc;
        self.isPushed = isPushed;
        
        [self addSubview:self.scrollView];
        [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        // 不是push过来的，添加下拉刷新
        if (!isPushed) {
//            [self.viewModel refreshNewListWithSuccess:^(NSArray * _Nonnull list) {
//                [self setModels:list index:0];
//            } failure:^(NSError * _Nonnull error) {
//                NSLog(@"%@", error);
//            }];
            
//            self.scrollView.mj_header = [MJRefreshNormalHeader headerWithRefreshingBlock:^{
//                [self.videos removeAllObjects];
//
//                [self.viewModel refreshNewListWithSuccess:^(NSArray * _Nonnull list) {
//                    [self setModels:list index:0];
//                    [self.scrollView.mj_header endRefreshing];
//                    [self.scrollView.mj_footer endRefreshing];
//                } failure:^(NSError * _Nonnull error) {
//                    NSLog(@"%@", error);
//                    [self.scrollView.mj_header endRefreshing];
//                    [self.scrollView.mj_footer endRefreshing];
//                }];
//            }];
            
            self.scrollView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
                [self.player pausePlay];
                // 当播放索引为最后一个时才会触发下拉刷新
                self.currentPlayIndex = self.videos.count - 1;
                
                [self.viewModel refreshMoreListWithSuccess:^(NSArray * _Nonnull list) {
                    self.isRefreshMore = NO;
                    
                    if (list) {
                        if (self.videos.count == 0) {
                            [self setModels:list index:0];
                        }else {
                            [self resetModels:list];
                        }
                        [self.scrollView.mj_footer endRefreshing];
                    }else {
                        [self.scrollView.mj_footer endRefreshingWithNoMoreData];
                    }
                } failure:^(NSError * _Nonnull error) {
                    NSLog(@"%@", error);
                    self.isRefreshMore = NO;
                    [self.scrollView.mj_footer endRefreshingWithNoMoreData];
                }];
            }];
            
//            [self.scrollView addGestureRecognizer:self.panGesture];
        }
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat controlW = CGRectGetWidth(self.scrollView.frame);
    CGFloat controlH = CGRectGetHeight(self.scrollView.frame);
    
    self.topView.frame   = CGRectMake(0, 0, controlW, controlH);
    self.ctrView.frame   = CGRectMake(0, controlH, controlW, controlH);
    self.btmView.frame   = CGRectMake(0, 2 * controlH, controlW, controlH);
}

#pragma mark - Public Methods
- (void)setModels:(NSArray *)models index:(NSInteger)index {
    [self.videos removeAllObjects];
    [self.videos addObjectsFromArray:models];
    
    self.index = index;
    self.currentPlayIndex = index;
    
    if (models.count == 0) return;
    
    if (models.count == 1) {
        [self.ctrView removeFromSuperview];
        [self.btmView removeFromSuperview];
        
        self.scrollView.contentSize = CGSizeMake(0, SCREEN_HEIGHT);
        
        self.topView.hidden = NO;
        self.topView.model = self.videos.firstObject;
        
        [self playVideoFrom:self.topView];
    }else if (models.count == 2) {
        [self.btmView removeFromSuperview];
        
        self.scrollView.contentSize = CGSizeMake(0, SCREEN_HEIGHT * 2);
        
        self.topView.hidden = NO;
        self.ctrView.hidden = NO;
        self.topView.model  = self.videos.firstObject;
        self.ctrView.model  = self.videos.lastObject;
        
        if (index == 1) {
            self.scrollView.contentOffset = CGPointMake(0, SCREEN_HEIGHT);
            
            [self playVideoFrom:self.ctrView];
        }else {
            [self playVideoFrom:self.topView];
        }
    }else {
        self.topView.hidden = NO;
        self.ctrView.hidden = NO;
        self.btmView.hidden = NO;
        
        if (index == 0) {   // 如果是第一个，则显示上视图，且预加载中下视图
            self.topView.model = self.videos[index];
            self.ctrView.model = self.videos[index + 1];
            self.btmView.model = self.videos[index + 2];
            
            // 播放第一个
            [self playVideoFrom:self.topView];
        }else if (index == models.count - 1) { // 如果是最后一个，则显示最后视图，且预加载前两个
            self.btmView.model = self.videos[index];
            self.ctrView.model = self.videos[index - 1];
            self.topView.model = self.videos[index - 2];
            
            // 显示最后一个
            self.scrollView.contentOffset = CGPointMake(0, SCREEN_HEIGHT * 2);
            // 播放最后一个
            [self playVideoFrom:self.btmView];
        }else { // 显示中间，播放中间，预加载上下
            self.ctrView.model = self.videos[index];
            self.topView.model = self.videos[index - 1];
            self.btmView.model = self.videos[index + 1];
            
            // 显示中间
            self.scrollView.contentOffset = CGPointMake(0, SCREEN_HEIGHT);
            // 播放中间
            [self playVideoFrom:self.ctrView];
        }
    }
}

- (void)resetModels:(NSArray *)models {
//    [self.videos removeAllObjects];
//    [self.videos addObjectsFromArray:models];
    [self.videos addObjectsFromArray:models];
}

// 添加播放数据后，重置index，防止出现错位的情况
- (void)addModels:(NSArray *)models index:(NSInteger)index {
    [self.videos addObjectsFromArray:models];
    
    self.index = index;
    self.currentPlayIndex = index;
    
    if (self.videos.count == 0) return;
    
    if (self.videos.count == 1) {
        [self.ctrView removeFromSuperview];
        [self.btmView removeFromSuperview];
        
        self.scrollView.contentSize = CGSizeMake(0, SCREEN_HEIGHT);
        
        self.topView.hidden = NO;
        self.topView.model = self.videos.firstObject;
        
        [self playVideoFrom:self.topView];
    }else if (self.videos.count == 2) {
        [self.btmView removeFromSuperview];
        
        self.scrollView.contentSize = CGSizeMake(0, SCREEN_HEIGHT * 2);
        
        self.topView.hidden = NO;
        self.ctrView.hidden = NO;
        self.topView.model = self.videos.firstObject;
        self.ctrView.model = self.videos.lastObject;
        
        if (index == 1) {
            self.scrollView.contentOffset = CGPointMake(0, SCREEN_HEIGHT);
            
            [self playVideoFrom:self.ctrView];
        }else {
            [self playVideoFrom:self.topView];
        }
    }else {
        self.topView.hidden = NO;
        self.ctrView.hidden = NO;
        self.btmView.hidden = NO;
        
        if (index == 0) {   // 如果是第一个，则显示上视图，且预加载中下视图
            self.topView.model = self.videos[index];
            self.ctrView.model = self.videos[index + 1];
            self.btmView.model = self.videos[index + 2];
            
            // 播放第一个
            [self playVideoFrom:self.topView];
        }else if (index == self.videos.count - 1) { // 如果是最后一个，则显示最后视图，且预加载前两个
            self.btmView.model = self.videos[index];
            self.ctrView.model = self.videos[index - 1];
            self.topView.model = self.videos[index - 2];
            
            // 显示最后一个
            self.scrollView.contentOffset = CGPointMake(0, SCREEN_HEIGHT * 2);
            // 播放最后一个
            [self playVideoFrom:self.btmView];
        }else { // 显示中间，播放中间，预加载上下
            self.ctrView.model = self.videos[index];
            self.topView.model = self.videos[index - 1];
            self.btmView.model = self.videos[index + 1];
            
            // 显示中间
            self.scrollView.contentOffset = CGPointMake(0, SCREEN_HEIGHT);
            // 播放中间
            [self playVideoFrom:self.ctrView];
        }
    }
}

- (void)pause {
    if (self.player.isPlaying) {
        self.isPlaying_beforeScroll = YES;
    }else {
        self.isPlaying_beforeScroll = NO;
    }
    
    [self.player pausePlay];
}

- (void)resume {
    if (self.isPlaying_beforeScroll) {
        [self.player resumePlay];
    }
}

- (void)destoryPlayer {
    self.scrollView.delegate = nil;
    [self.player removeVideo];
}

#pragma mark - Private Methods
- (void)playVideoFrom:(GKDYVideoControlView *)fromView {
    // 移除原来的播放
    [self.player removeVideo];
    
    // 取消原来视图的代理
    self.currentPlayView.delegate = nil;
    
    // 切换播放视图
    self.currentPlayId    = fromView.model.post_id;
    self.currentPlayView  = fromView;
    self.currentPlayIndex = [self indexOfModel:fromView.model];
    
    NSLog(@"当前播放索引====%zd", self.currentPlayIndex);

    // 设置新视图的代理
    self.currentPlayView.delegate = self;
    
    // 重新播放
    @weakify(self);
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        @strongify(self);
        [self.player playVideoWithView:fromView.coverImgView url:fromView.model.video_url];
    });
}

// 获取当前播放内容的索引
- (NSInteger)indexOfModel:(GKDYVideoModel *)model {
    __block NSInteger index = 0;
    [self.videos enumerateObjectsUsingBlock:^(GKDYVideoModel *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([model.post_id isEqualToString:obj.post_id]) {
            index = idx;
        }
    }];
    return index;
}

#pragma mark - UIScrollViewDelegate
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (self.currentPlayIndex == 0 && scrollView.contentOffset.y < 0) {
        self.scrollView.contentOffset = CGPointZero;
    }
    
    // slier处理
    if (scrollView.contentOffset.y == 0 || scrollView.contentOffset.y == SCREEN_HEIGHT || scrollView.contentOffset.y == 2 * SCREEN_HEIGHT) {
        if ([self.delegate respondsToSelector:@selector(videoView:didScrollIsCritical:)]) {
            [self.delegate videoView:self didScrollIsCritical:YES];
        }
    }else {
        if ([self.delegate respondsToSelector:@selector(videoView:didScrollIsCritical:)]) {
            [self.delegate videoView:self didScrollIsCritical:NO];
        }
    }
    
    // 小于等于三个，不用处理
    if (self.videos.count <= 3) return;
    
    // 上滑到第一个
    if (self.index == 0 && scrollView.contentOffset.y <= SCREEN_HEIGHT) {
        return;
    }
    // 下滑到最后一个
    if (self.index > 0 && self.index == self.videos.count - 1 && scrollView.contentOffset.y > SCREEN_HEIGHT) {
        return;
    }
    
    // 判断是从中间视图上滑还是下滑
    if (scrollView.contentOffset.y >= 2 * SCREEN_HEIGHT) {  // 上滑
        [self.player removeVideo];  // 在这里移除播放，解决闪动的bug
        if (self.index == 0) {
            self.index += 2;
            
            scrollView.contentOffset = CGPointMake(0, SCREEN_HEIGHT);
            
            self.topView.model = self.ctrView.model;
            self.ctrView.model = self.btmView.model;
            
        }else {
            self.index += 1;
            
            if (self.index == self.videos.count - 1) {
                self.ctrView.model = self.videos[self.index - 1];
            }else {
                scrollView.contentOffset = CGPointMake(0, SCREEN_HEIGHT);
                
                self.topView.model = self.ctrView.model;
                self.ctrView.model = self.btmView.model;
            }
        }
        if (self.index < self.videos.count - 1 && self.videos.count >= 3) {
            self.btmView.model = self.videos[self.index + 1];
        }
    }else if (scrollView.contentOffset.y <= 0) { // 下滑
        [self.player removeVideo];  // 在这里移除播放，解决闪动的bug
        if (self.index == 1) {
            self.topView.model = self.videos[self.index - 1];
            self.ctrView.model = self.videos[self.index];
            self.btmView.model = self.videos[self.index + 1];
            self.index -= 1;
        }else {
            if (self.index == self.videos.count - 1) {
                self.index -= 2;
            }else {
                self.index -= 1;
            }
            scrollView.contentOffset = CGPointMake(0, SCREEN_HEIGHT);
            
            self.btmView.model = self.ctrView.model;
            self.ctrView.model = self.topView.model;
            
            if (self.index > 0) {
                self.topView.model = self.videos[self.index - 1];
            }
        }
    }
    
    if (self.isPushed) return;
    
    // 自动刷新，如果想要去掉自动刷新功能，去掉下面代码即可
    if (scrollView.contentOffset.y == SCREEN_HEIGHT) {
        if (self.isRefreshMore) return;
        
        // 播放到倒数第二个时，请求更多内容
        if (self.currentPlayIndex == self.videos.count - 3) {
            self.isRefreshMore = YES;
            [self refreshMore];
        }
    }
    
    if (scrollView.contentOffset.y == 2 * SCREEN_HEIGHT) {
        [self refreshMore];
    }
}

// 结束滚动后开始播放
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if (scrollView.contentOffset.y == 0) {
        if (self.currentPlayId == self.topView.model.post_id) return;
        [self playVideoFrom:self.topView];
    }else if (scrollView.contentOffset.y == SCREEN_HEIGHT) {
        if (self.currentPlayId == self.ctrView.model.post_id) return;
        [self playVideoFrom:self.ctrView];
    }else if (scrollView.contentOffset.y == 2 * SCREEN_HEIGHT) {
        if (self.currentPlayId == self.btmView.model.post_id) return;
        [self playVideoFrom:self.btmView];
    }
}

- (void)refreshMore {
    [self.viewModel refreshMoreListWithSuccess:^(NSArray * _Nonnull list) {
        self.isRefreshMore = NO;
        if (list) {
            [self.videos addObjectsFromArray:list];
            [self.scrollView.mj_footer endRefreshing];
        }else {
            [self.scrollView.mj_footer endRefreshingWithNoMoreData];
        }
    } failure:^(NSError * _Nonnull error) {
        NSLog(@"%@", error);
        self.isRefreshMore = NO;
        [self.scrollView.mj_footer endRefreshingWithNoMoreData];
    }];
}

#pragma mark - Gesture
- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    if (self.currentPlayIndex == 0) {
        CGPoint translation = [panGesture translationInView:panGesture.view];
        
        CGFloat absX = fabs(translation.x);
        CGFloat absY = fabs(translation.y);
        
//        if (MAX(absX, absY) < 10)
//            return;
        if (absX > absY ) { // 左右滑动
            return;
        } else if (absY > absX) {
            if (translation.y < 0) {
                //向上滑动
            }else{
                //向下滑动
            }
        }
        
        CGPoint location = [panGesture locationInView:panGesture.view];
        
        switch (panGesture.state) {
            case UIGestureRecognizerStateBegan: {
                self.startLocationY = location.y;
            }
                break;
            case UIGestureRecognizerStateChanged: {
                CGFloat distance = location.y - self.startLocationY;
                if (distance > 0) { // 只要distance>0且没松手 就认为是下滑
                    self.scrollView.panGestureRecognizer.enabled = NO;
                }
                
                if (self.scrollView.panGestureRecognizer.enabled == NO) {
                    if ([self.delegate respondsToSelector:@selector(videoView:didPanWithDistance:isEnd:)]) {
                        [self.delegate videoView:self didPanWithDistance:distance isEnd:NO];
                    }
                }
            }
                break;
            case UIGestureRecognizerStateFailed:
            case UIGestureRecognizerStateCancelled:
            case UIGestureRecognizerStateEnded: {
                CGFloat distance = location.y - self.startLocationY;
                if ([self.delegate respondsToSelector:@selector(videoView:didPanWithDistance:isEnd:)]) {
                    [self.delegate videoView:self didPanWithDistance:distance isEnd:YES];
                }
                
                self.scrollView.panGestureRecognizer.enabled = YES;
            }
                break;
                
            default:
                break;
        }
        
        [panGesture setTranslation:CGPointZero inView:panGesture.view];
    }
}

// 允许多个手势响应
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

#pragma mark - GKDYVideoPlayerDelegate
- (void)player:(GKDYVideoPlayer *)player statusChanged:(GKDYVideoPlayerStatus)status {
    switch (status) {
        case GKDYVideoPlayerStatusUnload:   // 未加载
            
            break;
        case GKDYVideoPlayerStatusPrepared:   // 准备播放
            
            break;
        case GKDYVideoPlayerStatusLoading: {     // 加载中
            [self.currentPlayView startLoading];
            [self.currentPlayView hidePlayBtn];
        }
            break;
        case GKDYVideoPlayerStatusPlaying: {    // 播放中
            [self.currentPlayView stopLoading];
            [self.currentPlayView hidePlayBtn];
        }
            break;
        case GKDYVideoPlayerStatusPaused: {     // 暂停
            [self.currentPlayView stopLoading];
            [self.currentPlayView showPlayBtn];
        }
            break;
        case GKDYVideoPlayerStatusEnded: {   // 播放结束
            // 重新开始播放
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.player resetPlay];
            });
        }
            break;
        case GKDYVideoPlayerStatusError:   // 错误
            
            break;
            
        default:
            break;
    }
}

- (void)player:(GKDYVideoPlayer *)player currentTime:(float)currentTime totalTime:(float)totalTime progress:(float)progress {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.currentPlayView setProgress:progress];
    });
}

#pragma mark - GKDYVideoControlViewDelegate
- (void)controlViewDidClickSelf:(GKDYVideoControlView *)controlView {
    if (self.player.isPlaying) {
        [self.player pausePlay];
    }else {
        [self.player resumePlay];
    }
}

- (void)controlViewDidClickIcon:(GKDYVideoControlView *)controlView {
    if ([self.delegate respondsToSelector:@selector(videoView:didClickIcon:)]) {
        [self.delegate videoView:self didClickIcon:controlView.model];
    }
}

- (void)controlViewDidClickPriase:(GKDYVideoControlView *)controlView {
    if ([self.delegate respondsToSelector:@selector(videoView:didClickPraise:)]) {
        [self.delegate videoView:self didClickPraise:controlView.model];
    }
}

- (void)controlViewDidClickComment:(GKDYVideoControlView *)controlView {
    if ([self.delegate respondsToSelector:@selector(videoView:didClickComment:)]) {
        [self.delegate videoView:self didClickComment:controlView.model];
    }
}

- (void)controlViewDidClickShare:(GKDYVideoControlView *)controlView {
    if ([self.delegate respondsToSelector:@selector(videoView:didClickShare:)]) {
        [self.delegate videoView:self didClickShare:controlView.model];
    }
}

#pragma mark - 懒加载
- (GKDYVideoViewModel *)viewModel {
    if (!_viewModel) {
        _viewModel = [GKDYVideoViewModel new];
    }
    return _viewModel;
}

- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [UIScrollView new];
        _scrollView.pagingEnabled = YES;
        _scrollView.backgroundColor = [UIColor clearColor];
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.delegate = self;
        
        [_scrollView addSubview:self.topView];
        [_scrollView addSubview:self.ctrView];
        [_scrollView addSubview:self.btmView];
        _scrollView.contentSize = CGSizeMake(0, SCREEN_HEIGHT * 3);
        
        if (@available(iOS 11.0, *)) {
            _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _scrollView;
}

- (GKDYVideoControlView *)topView {
    if (!_topView) {
        _topView = [GKDYVideoControlView new];
        _topView.hidden = YES;
    }
    return _topView;
}

- (GKDYVideoControlView *)ctrView {
    if (!_ctrView) {
        _ctrView = [GKDYVideoControlView new];
        _ctrView.hidden = YES;
    }
    return _ctrView;
}

- (GKDYVideoControlView *)btmView {
    if (!_btmView) {
        _btmView = [GKDYVideoControlView new];
        _btmView.hidden = YES;
    }
    return _btmView;
}

- (NSMutableArray *)videos {
    if (!_videos) {
        _videos = [NSMutableArray new];
    }
    return _videos;
}

- (GKDYVideoPlayer *)player {
    if (!_player) {
        _player = [GKDYVideoPlayer new];
        _player.delegate = self;
    }
    return _player;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

@end
