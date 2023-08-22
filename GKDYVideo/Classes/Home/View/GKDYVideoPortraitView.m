//
//  GKDYVideoPortraitView.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoPortraitView.h"
#import "GKDYVideoItemButton.h"
#import "GKDoubleLikeView.h"

@interface GKDYVideoPortraitView()

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) GKDYVideoItemButton *shareBtn;

@property (nonatomic, strong) GKDYVideoItemButton *commentBtn;

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UIButton *danmuBtn;

@property (nonatomic, strong) UIButton *fullscreenBtn;

@property (nonatomic, strong) GKDoubleLikeView *doubleLikeView;

@property (nonatomic, strong) NSDate *lastDoubleTapTime;

@end

@implementation GKDYVideoPortraitView

@synthesize player = _player;

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.bottomView];
    [self.bottomView addSubview:self.contentLabel];
    [self.bottomView addSubview:self.nameLabel];
    [self.bottomView addSubview:self.shareBtn];
    [self.bottomView addSubview:self.commentBtn];
    [self.bottomView addSubview:self.likeView];
    [self.bottomView addSubview:self.iconView];
    [self addSubview:self.slider];
    [self addSubview:self.danmuBtn];
    [self addSubview:self.fullscreenBtn];
    [self addSubview:self.playBtn];
    
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_equalTo(300);
    }];
    
    [self.slider mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        make.bottom.equalTo(self);
        make.height.mas_equalTo(20);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.slider);
        make.bottom.equalTo(self.contentLabel.mas_top).offset(-10);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.slider);
        make.right.equalTo(self).offset(-80);
        make.bottom.equalTo(self.slider.mas_top).offset(-10);
    }];
    
    [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self);
        make.bottom.equalTo(self.slider.mas_top).offset(-10);
        make.width.height.mas_equalTo(60);
    }];
    
    [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.shareBtn);
        make.bottom.equalTo(self.shareBtn.mas_top).offset(-20);
        make.width.height.mas_equalTo(60);
    }];
    
    [self.likeView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.commentBtn);
        make.bottom.equalTo(self.commentBtn.mas_top).offset(-20);
        make.width.height.mas_equalTo(60);
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.likeView);
        make.bottom.equalTo(self.likeView.mas_top).offset(-20);
        make.width.height.mas_equalTo(50);
    }];
    
    [self.danmuBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(self).offset(-(GK_NOTCHED_SCREEN ? 200 : 160));
        make.right.equalTo(self.mas_centerX).offset(-40);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.fullscreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.danmuBtn);
        make.left.equalTo(self.danmuBtn.mas_right).offset(20);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
    
    [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self);
    }];
}

#pragma mark - ZFPlayerMediaControl
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

- (void)handleSingleTapped {
    id<ZFPlayerMediaPlayback> manager = self.player.currentPlayerManager;
    if (manager.isPlaying) {
        [manager pause];
        [self.slider showLargeSlider];
        self.playBtn.hidden = NO;
        self.playBtn.transform = CGAffineTransformMakeScale(3, 3);
        [UIView animateWithDuration:0.15 animations:^{
            self.playBtn.alpha = 1;
            self.playBtn.transform = CGAffineTransformIdentity;
        }];
    }else {
        [manager play];
        [self.slider showSmallSlider];
        [UIView animateWithDuration:0.15 animations:^{
            self.playBtn.alpha = 0;
        } completion:^(BOOL finished) {
            self.playBtn.hidden = YES;
        }];
    }
}

- (void)handleDoubleTapped:(UITapGestureRecognizer *)gesture {
    CGPoint point = [gesture locationInView:gesture.view];
    [self.doubleLikeView createAnimationWithPoint:point view:gesture.view completion:nil];
    [self.likeView startAnimationWithIsLike:YES];
    self.model.isLike = YES;
    if ([self.delegate respondsToSelector:@selector(didClickLike:)]) {
        [self.delegate didClickLike:self.model];
    }
}

- (void)setModel:(GKDYVideoModel *)model {
    _model = model;
    
    self.nameLabel.text = model.source_name;
    
    self.contentLabel.text = model.title;
    
    [self.shareBtn setTitle:@"0" forState:UIControlStateNormal];
    
    NSString *comment = model.comment.integerValue > 0 ? model.comment : @"0";
    [self.commentBtn setTitle:comment forState:UIControlStateNormal];
    
    NSString *like = model.like.integerValue > 0 ? model.like : @"0";
    [self.likeView setupLikeCount:like];
    [self.likeView setupLikeState:model.isLike];
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.author_avatar]];
}

#pragma mark - Action
- (void)userDidClick {
    if ([self.delegate respondsToSelector:@selector(didClickIcon:)]) {
        [self.delegate didClickIcon:self.model];
    }
}

- (void)likeDidClick {
    self.model.isLike = !self.model.isLike;
    if ([self.delegate respondsToSelector:@selector(didClickLike:)]) {
        [self.delegate didClickLike:self.model];
    }
}

- (void)commentDidClick {
    if ([self.delegate respondsToSelector:@selector(didClickComment:)]) {
        [self.delegate didClickComment:self.model];
    }
}

- (void)shareDidClick {
    if ([self.delegate respondsToSelector:@selector(didClickShare:)]) {
        [self.delegate didClickShare:self.model];
    }
}

- (void)danmuDidClick {
    if ([self.delegate respondsToSelector:@selector(didClickDanmu:)]) {
        [self.delegate didClickDanmu:self.model];
    }
}

- (void)fullscreenDidClick {
    if ([self.delegate respondsToSelector:@selector(didClickFullscreen:)]) {
        [self.delegate didClickFullscreen:self.model];
    }
}

- (void)sliderDragging:(BOOL)isDragging {
    self.bottomView.alpha = !isDragging;
}

- (void)willBeginDragging {
    self.bottomView.alpha = 0.4;
    self.danmuBtn.alpha = 0.4;
    self.fullscreenBtn.alpha = 0.4;
}

- (void)didEndDragging {
    self.bottomView.alpha = 1;
    self.danmuBtn.alpha = 1;
    self.fullscreenBtn.alpha = 1;
}

#pragma mark - Lazy
- (UIView *)bottomView {
    if (!_bottomView) {
        _bottomView = [[UIView alloc] init];
    }
    return _bottomView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.textColor = UIColor.whiteColor;
        _nameLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidClick)];
        [_nameLabel addGestureRecognizer:tap];
    }
    return _nameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:14];
        _contentLabel.textColor = UIColor.whiteColor;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

- (GKDYVideoSlider *)slider {
    if (!_slider) {
        _slider = [[GKDYVideoSlider alloc] init];
        
        @weakify(self);
        _slider.slideBlock = ^(BOOL isDragging) {
            @strongify(self);
            [self sliderDragging:isDragging];
        };
    }
    return _slider;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.layer.cornerRadius = 25;
        _iconView.layer.masksToBounds = YES;
        _iconView.layer.borderColor = UIColor.whiteColor.CGColor;
        _iconView.layer.borderWidth = 1.0f;
        _iconView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(userDidClick)];
        [_iconView addGestureRecognizer:tap];
    }
    return _iconView;
}

- (GKLikeView *)likeView {
    if (!_likeView) {
        _likeView = [[GKLikeView alloc] init];
        @weakify(self);
        _likeView.likeBlock = ^{
            @strongify(self);
            [self likeDidClick];
        };
    }
    return _likeView;
}

- (GKDYVideoItemButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [[GKDYVideoItemButton alloc] init];
        [_commentBtn setImage:[UIImage imageNamed:@"icon_home_comment"] forState:UIControlStateNormal];
        _commentBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_commentBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_commentBtn addTarget:self action:@selector(commentDidClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentBtn;
}

- (GKDYVideoItemButton *)shareBtn {
    if (!_shareBtn) {
        _shareBtn = [[GKDYVideoItemButton alloc] init];
        [_shareBtn setImage:[UIImage imageNamed:@"icon_home_share"] forState:UIControlStateNormal];
        _shareBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_shareBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(shareDidClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}

- (UIButton *)danmuBtn {
    if (!_danmuBtn) {
        _danmuBtn = [[UIButton alloc] init];
        [_danmuBtn setTitle:@"弹" forState:UIControlStateNormal];
        [_danmuBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _danmuBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _danmuBtn.layer.cornerRadius = 15;
        _danmuBtn.layer.masksToBounds = YES;
        _danmuBtn.layer.borderColor = UIColor.whiteColor.CGColor;
        _danmuBtn.layer.borderWidth = 0.5;
        [_danmuBtn addTarget:self action:@selector(danmuDidClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _danmuBtn;
}

- (UIButton *)fullscreenBtn {
    if (!_fullscreenBtn) {
        _fullscreenBtn = [[UIButton alloc] init];
        [_fullscreenBtn setTitle:@"全屏观看" forState:UIControlStateNormal];
        [_fullscreenBtn setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
        _fullscreenBtn.titleLabel.font = [UIFont systemFontOfSize:15];
        _fullscreenBtn.layer.cornerRadius = 15;
        _fullscreenBtn.layer.masksToBounds = YES;
        _fullscreenBtn.layer.borderColor = UIColor.whiteColor.CGColor;
        _fullscreenBtn.layer.borderWidth = 0.5;
        [_fullscreenBtn addTarget:self action:@selector(fullscreenDidClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullscreenBtn;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [[UIButton alloc] init];
        [_playBtn setImage:[UIImage imageNamed:@"ss_icon_pause"] forState:UIControlStateNormal];
        _playBtn.hidden = YES;
    }
    return _playBtn;
}

- (GKDoubleLikeView *)doubleLikeView {
    if (!_doubleLikeView) {
        _doubleLikeView = [[GKDoubleLikeView alloc] init];
    }
    return _doubleLikeView;
}

@end
