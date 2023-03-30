//
//  GKDYVideoPortraitView.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoPortraitView.h"
#import "GKDoubleLikeView.h"

@interface GKDYVideoPortraitView()

@property (nonatomic, strong) GKDoubleLikeView *likeView;

@end

@implementation GKDYVideoPortraitView

@synthesize player = _player;

- (instancetype)init {
    if (self = [super init]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.playBtn];
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

- (void)gestureSingleTapped:(ZFPlayerGestureControl *)gestureControl {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        [manager pause];
        self.playBtn.hidden = NO;
        self.playBtn.transform = CGAffineTransformMakeScale(3, 3);
        [UIView animateWithDuration:0.15 animations:^{
            self.playBtn.alpha = 1;
            self.playBtn.transform = CGAffineTransformIdentity;
        }];
    }else {
        [manager play];
        [UIView animateWithDuration:0.15 animations:^{
            self.playBtn.alpha = 0;
        } completion:^(BOOL finished) {
            self.playBtn.hidden = YES;
        }];
    }
}

- (void)gestureDoubleTapped:(ZFPlayerGestureControl *)gestureControl {
    UIGestureRecognizer *gesture = gestureControl.doubleTap;
    CGPoint point = [gesture locationInView:gesture.view];
    [self.likeView createAnimationWithPoint:point view:gesture.view completion:nil];
    !self.likeBlock ?: self.likeBlock();
}

- (void)gestureBeganPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location {
    NSLog(@"began pan");
}

- (void)gestureChangedPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location withVelocity:(CGPoint)velocity {
    NSLog(@"change pan");
}

- (void)gestureEndedPan:(ZFPlayerGestureControl *)gestureControl panDirection:(ZFPanDirection)direction panLocation:(ZFPanLocation)location {
    NSLog(@"ended pan");
}

#pragma mark - Lazy
- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[UIImage imageNamed:@"ss_icon_pause"] forState:UIControlStateNormal];
        _playBtn.hidden = YES;
    }
    return _playBtn;
}

- (GKDoubleLikeView *)likeView {
    if (!_likeView) {
        _likeView = [[GKDoubleLikeView alloc] init];
    }
    return _likeView;
}

@end
