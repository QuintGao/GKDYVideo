//
//  GKDYVideoFullscreenView.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/5/8.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoFullscreenView.h"
#import "GKDoubleLikeView.h"

@interface GKDYVideoFullscreenView()

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) UIView *leftView;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UIView *rightView;
@property (nonatomic, strong) UIButton *playBtn;
@property (nonatomic, strong) UIButton *speedBtn;

@property (nonatomic, strong) NSArray *speeds;
@property (nonatomic, assign) NSInteger currentSpeed;

@property (nonatomic, strong) GKDoubleLikeView *likeView;
@property (nonatomic, strong) NSDate *lastDoubleTapTime;

@end

@implementation GKDYVideoFullscreenView

- (instancetype)init {
    if (self = [super init]) {
        [self initUI];
        self.speeds = @[@1, @1.5, @2, @0.5];
        self.currentSpeed = 0;
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.leftView];
    [self.leftView addSubview:self.closeBtn];
    [self.bottomView addSubview:self.rightView];
    [self.rightView addSubview:self.playBtn];
    [self.rightView addSubview:self.speedBtn];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.equalTo(self);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(44);
    }];
    
    [self.leftView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.bottomView).offset(10);
        make.top.bottom.equalTo(self.bottomView);
        make.width.mas_equalTo(58);
    }];
    
    [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.leftView);
    }];
    
    [self.rightView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self.bottomView).offset(-10);
        make.top.bottom.equalTo(self.bottomView);
        make.width.mas_equalTo(100);
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.bottom.equalTo(self.rightView);
        make.right.equalTo(self.rightView.mas_centerX);
    }];
    
    [self.speedBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.top.bottom.equalTo(self.rightView);
        make.left.equalTo(self.rightView.mas_centerX);
    }];
}

#pragma mark - ZFPlayerMediaControl
@synthesize player = _player;
- (void)setPlayer:(ZFPlayerController *)player {
    _player = player;
    
    self.playBtn.selected = player.currentPlayerManager.isPlaying;
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

- (void)gestureBeganPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location {
    [self closeAction];
}

- (void)handleSingleTapped {
    [self playAction];
}

- (void)handleDoubleTapped:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:gesture.view];
    [self.likeView createAnimationWithPoint:point view:gesture.view completion:nil];
    !self.likeBlock ?: self.likeBlock();
}

#pragma mark - action
- (void)closeAction {
    !self.closeFullscreenBlock ?: self.closeFullscreenBlock();
}

- (void)playAction {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        [manager pause];
        self.playBtn.selected = NO;
    }else {
        [manager play];
        self.playBtn.selected = YES;
    }
}

- (void)speedAction {
    self.currentSpeed++;
    if (self.currentSpeed == self.speeds.count) {
        self.currentSpeed = 0;
    }
    float speed = [self.speeds[self.currentSpeed] floatValue];
    self.player.currentPlayerManager.rate = speed;
    [self.speedBtn setTitle:[NSString stringWithFormat:@"%@x", self.speeds[self.currentSpeed]] forState:UIControlStateNormal];
}

#pragma mark - lazy
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
    }
    return _bottomView;
}

- (UIView *)leftView {
    if (!_leftView) {
        _leftView = [[UIView alloc] init];
        _leftView.backgroundColor = UIColor.darkGrayColor;
        _leftView.layer.cornerRadius = 5;
        _leftView.layer.masksToBounds = YES;
    }
    return _leftView;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        [_closeBtn setImage:[UIImage imageNamed:@"icon_feedback_close_Normal"] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UIView *)rightView {
    if (!_rightView) {
        _rightView = [[UIView alloc] init];
        _rightView.backgroundColor = UIColor.darkGrayColor;
        _rightView.layer.cornerRadius = 5;
        _rightView.layer.masksToBounds = YES;
    }
    return _rightView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[UIImage imageNamed:@"icon_modern_feed_play_Normal"] forState:UIControlStateNormal];
        [_playBtn setImage:[UIImage imageNamed:@"icon_music_pause_new_Normal"] forState:UIControlStateSelected];
        [_playBtn addTarget:self action:@selector(playAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _playBtn;
}

- (UIButton *)speedBtn {
    if (!_speedBtn) {
        _speedBtn = [[UIButton alloc] init];
        [_speedBtn setTitle:@"1x" forState:UIControlStateNormal];
        [_speedBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _speedBtn.titleLabel.font = [UIFont systemFontOfSize:14];
        [_speedBtn addTarget:self action:@selector(speedAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _speedBtn;
}

- (GKDoubleLikeView *)likeView {
    if (!_likeView) {
        _likeView = [[GKDoubleLikeView alloc] init];
    }
    return _likeView;
}

@end
