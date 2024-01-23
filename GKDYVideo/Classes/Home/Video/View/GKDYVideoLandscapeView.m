//
//  GKDYVideoLandscapeView.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoLandscapeView.h"
#import "GKDYVideoStatusBar.h"
#import "GKDYVideoMaskView.h"
#import "GKDoubleLikeView.h"
#import <GKSliderView/GKSliderView.h>
#import "UIButton+GKCategory.h"
#import <ZFPlayer/ZFReachabilityManager.h>
#import "GKDYVideoPreviewView.h"
#import "GKDYTools.h"

@interface GKDYVideoLandscapeView()<GKSliderViewDelegate, GKSliderViewPreviewDelegate>

// 顶部
@property (nonatomic, strong) GKDYVideoMaskView *topContainerView;

@property (nonatomic, strong) GKDYVideoStatusBar *statusBar;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *contentLabel;

// 底部
@property (nonatomic, strong) GKDYVideoMaskView *bottomContainerView;

@property (nonatomic, strong) GKSliderView *sliderView;

@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UIButton *likeBtn;

@property (nonatomic, strong) UIButton *exitBtn;

@property (nonatomic, strong) GKDoubleLikeView *likeView;
@property (nonatomic, strong) NSDate *lastDoubleTapTime;

@property (nonatomic, assign) BOOL isDragging;
@property (nonatomic ,assign) BOOL isSeeking;

@end

@implementation GKDYVideoLandscapeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.topContainerView];
    [self.topContainerView addSubview:self.statusBar];
    [self.topContainerView addSubview:self.backBtn];
    [self.topContainerView addSubview:self.contentLabel];
    [self.topContainerView addSubview:self.nameLabel];
    
    [self addSubview:self.bottomContainerView];
    [self.bottomContainerView addSubview:self.sliderView];
    [self.bottomContainerView addSubview:self.playBtn];
    [self.bottomContainerView addSubview:self.timeLabel];
    [self.bottomContainerView addSubview:self.likeBtn];
    [self.bottomContainerView addSubview:self.exitBtn];
    
    [self.topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(80);
    }];
    
    [self.statusBar mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topContainerView.mas_safeAreaLayoutGuideTop);
        make.left.equalTo(self.topContainerView.mas_safeAreaLayoutGuideLeft).offset(10);
        make.right.equalTo(self.topContainerView.mas_safeAreaLayoutGuideRight).offset(-10);
        make.height.mas_equalTo(20);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.statusBar.mas_bottom).offset(5);
        make.left.equalTo(self.statusBar).offset(2);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backBtn).offset(3);
        make.left.equalTo(self.backBtn.mas_right).offset(5);
        make.right.equalTo(self.statusBar.mas_right).offset(-20);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentLabel);
        make.top.equalTo(self.contentLabel.mas_bottom).offset(5);
    }];
    
    [self.bottomContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.left.right.equalTo(self);
        make.height.mas_equalTo(80);
    }];
    
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideLeft).offset(10);
        make.right.equalTo(self.bottomContainerView.mas_safeAreaLayoutGuideRight).offset(-10);
        make.bottom.equalTo(self.playBtn.mas_top).offset(-10);
        make.height.mas_equalTo(10);
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.sliderView);
        make.bottom.equalTo(self.bottomContainerView).offset(-10);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playBtn);
        make.left.equalTo(self.playBtn.mas_right).offset(10);
    }];
    
    [self.likeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playBtn);
        make.right.equalTo(self.exitBtn.mas_left).offset(-20);
    }];
    
    [self.exitBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.playBtn);
        make.right.equalTo(self.sliderView.mas_right);
    }];
}

- (void)setModel:(GKDYVideoModel *)model {
    _model = model;
    
    self.contentLabel.text = model.title;
    self.nameLabel.text = model.source_name;
    self.likeBtn.selected = model.isLike;
}

- (void)startTimer {
    [self.statusBar startTimer];
}

- (void)destoryTimer {
    [self.statusBar destoryTimer];
}

#pragma mark - ZFPlayerMediaControl
@synthesize player = _player;
- (void)setPlayer:(ZFPlayerController *)player {
    _player = player;
    
    GKDYVideoPreviewView *videoPreview = (GKDYVideoPreviewView *)self.sliderView.preview;
    videoPreview.player = player;
    
    self.playBtn.selected = player.currentPlayerManager.isPlaying;
    [self setNetworkState];
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer orientationDidChanged:(ZFOrientationObserver *)observer {
    if (videoPlayer.isFullScreen) {
        [self showContainerView:NO];
        [self cancelAutoHidden];
        [self performSelector:@selector(hideContainerView:) withObject:@(YES) afterDelay:5.0f];
    }
}

- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    CGFloat diff = [NSDate date].timeIntervalSince1970 - self.lastDoubleTapTime.timeIntervalSince1970;
    if (diff < 0.6) {
        [self handleDoubleTapped:gestureControl.singleTap];
        self.lastDoubleTapTime = [NSDate date];
    }else {
        [self handleSingleTapped];
    }
}

- (void)gestureDoubleTapped:(ZFPlayerGestureControl *)gestureControl {
    [self handleDoubleTapped:gestureControl.doubleTap];
    self.lastDoubleTapTime = [NSDate date];
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer reachabilityChanged:(ZFReachabilityStatus)status {
    [self setNetworkState];
}

- (void)videoPlayer:(ZFPlayerController *)videoPlayer currentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    if (self.isDragging) return;
    if (self.isSeeking) return;
    self.sliderView.value = self.player.progress;
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", [GKDYTools convertTimeSecond:currentTime], [GKDYTools convertTimeSecond:totalTime]];
}

- (void)handleSingleTapped {
    !self.singleTapBlock ?: self.singleTapBlock();
}

- (void)handleDoubleTapped:(UITapGestureRecognizer *)gesture {
    [self cancelAutoHidden];
    
    CGPoint point = [gesture locationInView:gesture.view];
    @weakify(self);
    [self.likeView createAnimationWithPoint:point view:gesture.view completion:^{
        @strongify(self);
        [self performSelector:@selector(hideContainerView) withObject:nil afterDelay:5.0f];
    }];
    self.model.isLike = YES;
    self.likeBtn.selected = self.model.isLike;
    !self.likeBlock ?: self.likeBlock(self.model);
}

#pragma mark - Public
- (void)showContainerView:(BOOL)animated {
    [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
    }];
    
    [self.bottomContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self);
    }];
    
    self.topContainerView.hidden = NO;
    self.bottomContainerView.hidden = NO;
    
    NSTimeInterval duration = animated ? 0.2 : 0;
    
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isContainerShow = YES;
    }];
}

- (void)hideContainerView {
    [self hideContainerView:YES];
}

- (void)hideContainerView:(BOOL)animated {
    [self.topContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(-80);
    }];
    
    [self.bottomContainerView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(80);
    }];
    
    NSTimeInterval duration = animated ? 0.15 : 0;
    
    [UIView animateWithDuration:duration animations:^{
        [self layoutIfNeeded];
    } completion:^(BOOL finished) {
        self.isContainerShow = NO;
        self.topContainerView.hidden = YES;
        self.bottomContainerView.hidden = YES;
    }];
}

- (void)autoHide {
    [self cancelAutoHidden];
    
    if (self.isContainerShow) {
        [self hideContainerView:YES];
    }else {
        [self showContainerView:YES];
        [self performSelector:@selector(hideContainerView) withObject:nil afterDelay:5.0];
    }
}

- (void)cancelAutoHidden {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideContainerView) object:nil];
}

- (void)setNetworkState {
    NSString *net = @"WIFI";
    switch (ZFReachabilityManager.sharedManager.networkReachabilityStatus) {
        case ZFReachabilityStatusReachableViaWiFi:
            net = @"WIFI";
            break;
        case ZFReachabilityStatusNotReachable:
            net = @"无网络";
            break;
        case ZFReachabilityStatusReachableVia2G:
            net = @"2G";
            break;
        case ZFReachabilityStatusReachableVia3G:
            net = @"3G";
            break;
        case ZFReachabilityStatusReachableVia4G:
            net = @"4G";
            break;
        case ZFReachabilityStatusReachableVia5G:
            net = @"5G";
            break;
        default:
            net = @"未知";
            break;
    }
    self.statusBar.network = net;
}

#pragma mark - Action
- (void)backAction {
    [self cancelAutoHidden];
    [self.rotationManager rotate];
}

- (void)playAction {
    [self cancelAutoHidden];
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        [manager pause];
    }else {
        [manager play];
    }
    self.playBtn.selected = manager.isPlaying;
    [self autoHide];
}

- (void)likeAction {
    [self cancelAutoHidden];
    self.model.isLike = !self.model.isLike;
    self.likeBtn.selected = self.model.isLike;
    !self.likeBlock ?: self.likeBlock(self.model);
    [self autoHide];
}

- (void)exitAction {
    [self backAction];
}

#pragma mark - GKSliderViewDelegate
- (void)sliderView:(GKSliderView *)sliderView touchBegan:(float)value {
    self.isDragging = YES;
    [self showLargeSlider];
    [self cancelAutoHidden];
}

- (void)sliderView:(GKSliderView *)sliderView touchEnded:(float)value {
    self.isDragging = NO;
    [self showSmallSlider];
    [self autoHide];
}

#pragma mark - GKSliderViewPreviewDelegate
- (UIView *)sliderViewSetupPreview:(GKSliderView *)sliderView {
    GKDYVideoPreviewView *preview = [[GKDYVideoPreviewView alloc] init];
    preview.bounds = CGRectMake(0, 0, 120, 120);
    return preview;
}

- (CGFloat)sliderViewPreviewMargin:(GKSliderView *)sliderView {
    return 40;
}

- (void)sliderView:(GKSliderView *)sliderView preview:(UIView *)preview valueChanged:(float)value {
    GKDYVideoPreviewView *videoPreview = (GKDYVideoPreviewView *)preview;
    [videoPreview setPreviewValue:value];
}

- (void)showLargeSlider {
    self.sliderView.sliderBtn.transform = CGAffineTransformMakeScale(1.5, 1.5);
    self.sliderView.sliderHeight = 5;
}

- (void)showSmallSlider {
    self.sliderView.sliderBtn.transform = CGAffineTransformIdentity;
    self.sliderView.sliderHeight = 2;
}

#pragma mark - Lazy
- (GKDYVideoMaskView *)topContainerView {
    if (!_topContainerView) {
        _topContainerView = [[GKDYVideoMaskView alloc] initWithStyle:GKDYVideoMaskViewStyle_Top];
    }
    return _topContainerView;
}

- (GKDYVideoMaskView *)bottomContainerView {
    if (!_bottomContainerView) {
        _bottomContainerView = [[GKDYVideoMaskView alloc] initWithStyle:GKDYVideoMaskViewStyle_Bottom];
    }
    return _bottomContainerView;
}

- (GKDYVideoStatusBar *)statusBar {
    if (!_statusBar) {
        _statusBar = [[GKDYVideoStatusBar alloc] init];
    }
    return _statusBar;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setImage:[UIImage imageNamed:@"ic_back_white"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
        [_backBtn setEnlargeEdge:10];
    }
    return _backBtn;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont boldSystemFontOfSize:15];
        _contentLabel.textColor = UIColor.whiteColor;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = UIColor.whiteColor;
    }
    return _nameLabel;
}

- (GKSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[GKSliderView alloc] init];
        [_sliderView setThumbImage:[UIImage imageNamed:@"icon_slider"] forState:UIControlStateNormal];
        [_sliderView setThumbImage:[UIImage imageNamed:@"icon_slider"] forState:UIControlStateHighlighted];
        _sliderView.maximumTrackTintColor = UIColor.grayColor;
        _sliderView.minimumTrackTintColor = UIColor.whiteColor;
        _sliderView.sliderHeight = 2;
        _sliderView.delegate = self;
        _sliderView.previewDelegate = self;
        _sliderView.isPreviewChangePosition = NO;
        _sliderView.isSliderAllowTapped = YES;
        _sliderView.isSliderAllowDragged = YES;
    }
    return _sliderView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[UIImage imageNamed:@"icon_play"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"icon_pause"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
        [_playBtn setEnlargeEdge:10];
    }
    return _playBtn;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:13];
        _timeLabel.textColor = UIColor.whiteColor;
    }
    return _timeLabel;
}

- (UIButton *)likeBtn {
    if (!_likeBtn) {
        _likeBtn = [[UIButton alloc] init];
        [_likeBtn setImage:[UIImage imageNamed:@"ss_icon_star_normal"] forState:UIControlStateNormal];
        [_likeBtn setImage:[UIImage imageNamed:@"ss_icon_star_selected"] forState:UIControlStateSelected];
        [_likeBtn addTarget:self action:@selector(likeAction) forControlEvents:UIControlEventTouchUpInside];
        [_likeBtn setEnlargeEdge:10];
    }
    return _likeBtn;
}

- (UIButton *)exitBtn {
    if (!_exitBtn) {
        _exitBtn = [[UIButton alloc] init];
        [_exitBtn setImage:[UIImage imageNamed:@"ss_icon_shrinkscreen"] forState:UIControlStateNormal];
        [_exitBtn addTarget:self action:@selector(exitAction) forControlEvents:UIControlEventTouchUpInside];
        [_exitBtn setEnlargeEdge:10];
    }
    return _exitBtn;
}

- (GKDoubleLikeView *)likeView {
    if (!_likeView) {
        _likeView = [[GKDoubleLikeView alloc] init];
    }
    return _likeView;
}

@end
