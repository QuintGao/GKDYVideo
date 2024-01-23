//
//  GKDYVideoControlView.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYVideoControlView.h"
#import "GKLikeView.h"
#import "NSString+GKCategory.h"
#import "GKDYVideoItemButton.h"

@interface GKDYVideoControlView()

@property (nonatomic, strong) UIImageView           *iconView;
@property (nonatomic, strong) GKLikeView            *likeView;
@property (nonatomic, strong) GKDYVideoItemButton   *commentBtn;
@property (nonatomic, strong) GKDYVideoItemButton   *shareBtn;

@property (nonatomic, strong) UILabel               *nameLabel;
@property (nonatomic, strong) UILabel               *contentLabel;

@property (nonatomic, strong) UIButton                  *playBtn;

@property (nonatomic, strong) UILabel *label;

@end

@implementation GKDYVideoControlView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.coverImgView];
        [self addSubview:self.iconView];
        [self addSubview:self.likeView];
        [self addSubview:self.commentBtn];
        [self addSubview:self.shareBtn];
        [self addSubview:self.nameLabel];
        [self addSubview:self.contentLabel];
        [self addSubview:self.sliderView];
        
        [self addSubview:self.playBtn];
        [self addSubview:self.label];
        
        [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        CGFloat bottomM = TABBAR_HEIGHT;
        
        self.sliderView.frame = CGRectMake(0, SCREEN_HEIGHT - TABBAR_HEIGHT - 0.5, SCREEN_WIDTH, ADAPTATIONRATIO * 1.0f);
        
        [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self).offset(ADAPTATIONRATIO * 30.0f);
            make.bottom.equalTo(self).offset(-(ADAPTATIONRATIO * 30.0f + bottomM));
            make.width.mas_equalTo(ADAPTATIONRATIO * 504.0f);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentLabel);
            make.bottom.equalTo(self.contentLabel.mas_top).offset(-ADAPTATIONRATIO * 20.0f);
        }];
        
        [self.shareBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self).offset(-ADAPTATIONRATIO * 30.0f);
            make.bottom.equalTo(self.sliderView.mas_top).offset(-ADAPTATIONRATIO * 100.0f);
            make.width.height.mas_equalTo(ADAPTATIONRATIO * 110.0f);
        }];
        
        [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.shareBtn);
            make.bottom.equalTo(self.shareBtn.mas_top).offset(-ADAPTATIONRATIO * 45.0f);
            make.width.height.mas_equalTo(ADAPTATIONRATIO * 110.0f);
        }];
        
        [self.likeView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.shareBtn);
            make.bottom.equalTo(self.commentBtn.mas_top).offset(-ADAPTATIONRATIO * 45.0f);
            make.width.height.mas_equalTo(ADAPTATIONRATIO * 110.0f);
        }];
        
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.shareBtn);
            make.bottom.equalTo(self.likeView.mas_top).offset(-ADAPTATIONRATIO * 70.0f);
            make.width.height.mas_equalTo(ADAPTATIONRATIO * 100.0f);
        }];
        
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        [self.label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
    }
    return self;
}

//- (void)setModel:(GKAWEModel *)model {
//    _model = model;
//    
//    self.sliderView.value = 0;
//    
//    if (model.video.width.floatValue > model.video.height.floatValue) {
//        self.coverImgView.contentMode = UIViewContentModeScaleAspectFit;
//    }else {
//        self.coverImgView.contentMode = UIViewContentModeScaleAspectFill;
//    }
//    NSString *url = model.video.cover.url_list.firstObject;
//    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:url] placeholderImage:[UIImage imageNamed:@"img_video_loading"]];
//    self.nameLabel.text = [NSString stringWithFormat:@"@%@", model.author.nickname];
//    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.author.avatar_thumb.url_list.firstObject] placeholderImage:[UIImage imageNamed:@"placeholderimg"]];
//    self.contentLabel.text = model.desc;
//    
//    [self.likeView setupLikeState:model.is_like];
//    [self.likeView setupLikeCount:[model.statistics.digg_count gk_unitConvert]];
//    
//    [self.commentBtn setTitle:[model.statistics.comment_count gk_unitConvert] forState:UIControlStateNormal];
//    [self.shareBtn setTitle:[model.statistics.share_count gk_unitConvert] forState:UIControlStateNormal];
//    
//    self.label.text = [NSString stringWithFormat:@"第%zd个", model.index];
//}

#pragma mark - Public Methods
- (void)setProgress:(float)progress {
    self.sliderView.value = progress;
}

- (void)startLoading {
    [self.sliderView showLineLoading];
}

- (void)stopLoading {
    [self.sliderView hideLineLoading];
}

- (void)showPlayBtn {
    self.playBtn.hidden = NO;
}

- (void)hidePlayBtn {
    self.playBtn.hidden = YES;
}

- (void)showLikeAnimation {
    [self.likeView startAnimationWithIsLike:YES];
}

- (void)showUnLikeAnimation {
    [self.likeView startAnimationWithIsLike:NO];
}

#pragma mark - Action
- (void)controlViewDidClick {
    if ([self.delegate respondsToSelector:@selector(controlViewDidClickSelf:)]) {
        [self.delegate controlViewDidClickSelf:self];
    }
}

- (void)iconDidClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlViewDidClickIcon:)]) {
        [self.delegate controlViewDidClickIcon:self];
    }
}

- (void)praiseBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlViewDidClickPriase:)]) {
        [self.delegate controlViewDidClickPriase:self];
    }
}

- (void)commentBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlViewDidClickComment:)]) {
        [self.delegate controlViewDidClickComment:self];
    }
}

- (void)shareBtnClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(controlViewDidClickShare:)]) {
        [self.delegate controlViewDidClickShare:self];
    }
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    
    NSTimeInterval delayTime = 0.3f;
    
    if (touch.tapCount <= 1) {
        [self performSelector:@selector(controlViewDidClick) withObject:nil afterDelay:delayTime];
    }else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(controlViewDidClick) object:nil];
        
        if ([self.delegate respondsToSelector:@selector(controlView:touchesBegan:withEvent:)]) {
            [self.delegate controlView:self touchesBegan:touches withEvent:event];
        }
    }
}

#pragma mark - 懒加载
- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [UIImageView new];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImgView.clipsToBounds = YES;
    }
    return _coverImgView;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [UIImageView new];
        _iconView.layer.cornerRadius = ADAPTATIONRATIO * 50.0f;
        _iconView.layer.masksToBounds = YES;
        _iconView.layer.borderColor = [UIColor whiteColor].CGColor;
        _iconView.layer.borderWidth = 1.0f;
        _iconView.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *iconTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconDidClick:)];
        [_iconView addGestureRecognizer:iconTap];
    }
    return _iconView;
}

- (GKLikeView *)likeView {
    if (!_likeView) {
        _likeView = [GKLikeView new];
    }
    return _likeView;
}

- (GKDYVideoItemButton *)commentBtn {
    if (!_commentBtn) {
        _commentBtn = [GKDYVideoItemButton new];
        [_commentBtn setImage:[UIImage imageNamed:@"icon_home_comment"] forState:UIControlStateNormal];
        _commentBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_commentBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_commentBtn addTarget:self action:@selector(commentBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _commentBtn;
}

- (GKDYVideoItemButton *)shareBtn {
    if (!_shareBtn) {
        _shareBtn = [GKDYVideoItemButton new];
        [_shareBtn setImage:[UIImage imageNamed:@"icon_home_share"] forState:UIControlStateNormal];
        _shareBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_shareBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_shareBtn addTarget:self action:@selector(shareBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shareBtn;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont boldSystemFontOfSize:15.0f];
        _nameLabel.userInteractionEnabled = YES;
        
        UITapGestureRecognizer *nameTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(iconDidClick:)];
        [_nameLabel addGestureRecognizer:nameTap];
    }
    return _nameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [UILabel new];
        _contentLabel.numberOfLines = 0;
        _contentLabel.textColor = [UIColor whiteColor];
        _contentLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    return _contentLabel;
}

- (GKSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [GKSliderView new];
        _sliderView.isHideSliderBlock = YES;
        _sliderView.sliderHeight = ADAPTATIONRATIO * 1.0f;
        _sliderView.maximumTrackTintColor = [UIColor clearColor];
        _sliderView.minimumTrackTintColor = [UIColor whiteColor];
    }
    return _sliderView;
}

- (UIButton *)playBtn {
    if (!_playBtn) {
        _playBtn = [UIButton new];
        [_playBtn setImage:[UIImage imageNamed:@"ss_icon_pause"] forState:UIControlStateNormal];
        _playBtn.hidden = YES;
    }
    return _playBtn;
}

- (UILabel *)label {
    if (!_label) {
        _label = [[UILabel alloc] init];
        _label.font = [UIFont systemFontOfSize:30];
        _label.backgroundColor = UIColor.blackColor;
        _label.textColor = UIColor.whiteColor;
    }
    return _label;
}

@end
