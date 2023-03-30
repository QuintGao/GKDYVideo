//
//  GKDYVideoCell.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoCell.h"
#import "GKLikeView.h"
#import "GKDYPanGestureRecognizer.h"
#import "GKDYVideoItemButton.h"

@interface GKDYVideoCell()<GKSliderViewDelegate>

@property (nonatomic, strong) UILabel *contentLabel;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) GKDYVideoItemButton *shareBtn;

@property (nonatomic, strong) GKDYVideoItemButton *commentBtn;

@property (nonatomic, strong) GKLikeView *likeView;

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UIButton *danmuBtn;

@property (nonatomic, strong) UIButton *fullscreenBtn;

@end

@implementation GKDYVideoCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.coverImgView];
    [self addSubview:self.slider];
    [self addSubview:self.nameLabel];
    [self addSubview:self.contentLabel];
    [self addSubview:self.iconView];
    [self addSubview:self.likeView];
    [self addSubview:self.commentBtn];
    [self addSubview:self.shareBtn];
    [self addSubview:self.danmuBtn];
    [self addSubview:self.fullscreenBtn];
    
    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
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
        make.right.equalTo(self.mas_centerX).offset(-20);
        make.width.height.mas_equalTo(30);
    }];
    
    [self.fullscreenBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.danmuBtn);
        make.left.equalTo(self.danmuBtn.mas_right).offset(10);
        make.width.mas_equalTo(80);
        make.height.mas_equalTo(30);
    }];
}

- (void)setModel:(GKDYVideoModel *)model {
    _model = model;
    
    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.poster_small]];
    
    self.nameLabel.text = model.source_name;
    
    self.contentLabel.text = model.title;
    
    [self.shareBtn setTitle:@"0" forState:UIControlStateNormal];
    
    NSString *comment = model.comment.integerValue > 0 ? model.comment : @"0";
    [self.commentBtn setTitle:comment forState:UIControlStateNormal];
    
    NSString *like = model.like.integerValue > 0 ? model.like : @"0";
    [self.likeView setupLikeCount:like];
    [self.likeView setupLikeState:model.isLike];
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.author_avatar]];
    
    if (self.manager) {
        [self.manager requestPlayUrlWithModel:model completion:nil];
    }
}

- (void)showLargeSlider {
    [self.slider showLargeSlider];
}

- (void)showSmallSlider {
    [self.slider showSmallSlider];
}

- (void)resetView {
    self.slider.player = nil;
    self.slider.sliderView.value = 0;
}

- (void)showLikeAnimation {
    [self.likeView startAnimationWithIsLike:YES];
}

#pragma mark - Action
- (void)iconDidClick {
    if ([self.delegate respondsToSelector:@selector(videoCell:didClickIcon:)]) {
        [self.delegate videoCell:self didClickIcon:self.model];
    }
}

- (void)commentBtnClick {
    if ([self.delegate respondsToSelector:@selector(videoCell:didClickComment:)]) {
        [self.delegate videoCell:self didClickComment:self.model];
    }
}

- (void)shareBtnClick {
    if ([self.delegate respondsToSelector:@selector(videoCell:didClickShare:)]) {
        [self.delegate videoCell:self didClickShare:self.model];
    }
}

- (void)danmuBtnClick {
    if ([self.delegate respondsToSelector:@selector(videoCell:didClickDanmu:)]) {
        [self.delegate videoCell:self didClickDanmu:self.model];
    }
}

- (void)fullscreenBtnClick {
    [self.manager enterFullscreen];
}

- (void)sliderDragging:(BOOL)dragging {
    NSArray *views = @[self.contentLabel, self.nameLabel, self.shareBtn, self.commentBtn, self.likeView, self.iconView];
    
    [views enumerateObjectsUsingBlock:^(UIView *obj, NSUInteger idx, BOOL * _Nonnull stop) {
        obj.alpha = !dragging;
    }];
}

#pragma mark - Lazy
- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [[UIImageView alloc] init];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFit;
        _coverImgView.userInteractionEnabled = YES;
    }
    return _coverImgView;
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

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont boldSystemFontOfSize:16];
        _nameLabel.textColor = UIColor.whiteColor;
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

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [UIImageView new];
        _iconView.layer.cornerRadius = 25;
        _iconView.layer.masksToBounds = YES;
        _iconView.layer.borderColor = [UIColor whiteColor].CGColor;
        _iconView.layer.borderWidth = 1.0f;
        _iconView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *iconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconDidClick)];
        [_iconView addGestureRecognizer:iconTap];
    }
    return _iconView;
}

- (GKLikeView *)likeView {
    if (!_likeView) {
        _likeView = [GKLikeView new];
        
        @weakify(self);
        _likeView.likeBlock = ^{
            @strongify(self);
            if ([self.delegate respondsToSelector:@selector(videoCell:didClickLike:)]) {
                [self.delegate videoCell:self didClickLike:self.model];
            }
        };
    }
    return _likeView;
}

- (GKDYVideoItemButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [GKDYVideoItemButton new];
        [_commentBtn setImage:[UIImage imageNamed:@"icon_home_comment"] forState:UIControlStateNormal];
        _commentBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_commentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_commentBtn addTarget:self action:@selector(commentBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentBtn;
}

- (GKDYVideoItemButton *)shareBtn {
    if (!_shareBtn) {
        _shareBtn = [GKDYVideoItemButton new];
        [_shareBtn setImage:[UIImage imageNamed:@"icon_home_share"] forState:UIControlStateNormal];
        _shareBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(shareBtnClick) forControlEvents:UIControlEventTouchUpInside];
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
        [_danmuBtn addTarget:self action:@selector(danmuBtnClick) forControlEvents:UIControlEventTouchUpInside];
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
        [_fullscreenBtn addTarget:self action:@selector(fullscreenBtnClick) forControlEvents:UIControlEventTouchUpInside];
    }
    return _fullscreenBtn;
}

@end
