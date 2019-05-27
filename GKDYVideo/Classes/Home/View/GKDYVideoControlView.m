//
//  GKDYVideoControlView.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYVideoControlView.h"

@interface GKDYVideoItemButton : UIButton

@end

@implementation GKDYVideoItemButton

- (void)layoutSubviews {
    [super layoutSubviews];
    
    [self.imageView sizeToFit];
    [self.titleLabel sizeToFit];
    
    CGFloat width = self.frame.size.width;
    CGFloat height = self.frame.size.height;
    
    CGFloat imgW = self.imageView.frame.size.width;
    CGFloat imgH = self.imageView.frame.size.height;
    
    self.imageView.frame = CGRectMake((width - imgH) / 2, 0, imgW, imgH);
    
    CGFloat titleW = self.titleLabel.frame.size.width;
    CGFloat titleH = self.titleLabel.frame.size.height;
    
    self.titleLabel.frame = CGRectMake((width - titleW) / 2, height - titleH, titleW, titleH);
}

@end

@interface GKDYVideoControlView()

@property (nonatomic, strong) UIImageView           *iconView;
@property (nonatomic, strong) GKDYVideoItemButton   *praiseBtn;
@property (nonatomic, strong) GKDYVideoItemButton   *commentBtn;
@property (nonatomic, strong) GKDYVideoItemButton   *shareBtn;

@property (nonatomic, strong) UILabel               *nameLabel;
@property (nonatomic, strong) UILabel               *contentLabel;

//@property (nonatomic, strong) UIActivityIndicatorView   *loadingView;
@property (nonatomic, strong) UIButton                  *playBtn;

@end

@implementation GKDYVideoControlView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.coverImgView];
        [self addSubview:self.iconView];
        [self addSubview:self.praiseBtn];
        [self addSubview:self.commentBtn];
        [self addSubview:self.shareBtn];
        [self addSubview:self.nameLabel];
        [self addSubview:self.contentLabel];
        [self addSubview:self.sliderView];
        
//        [self addSubview:self.loadingView];
        [self addSubview:self.playBtn];
        
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
            make.bottom.equalTo(self.nameLabel.mas_top).offset(-ADAPTATIONRATIO * 50.0f);
            make.height.mas_equalTo(ADAPTATIONRATIO * 110.0f);
        }];
        
        [self.commentBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.shareBtn);
            make.bottom.equalTo(self.shareBtn.mas_top).offset(-ADAPTATIONRATIO * 45.0f);
            make.height.mas_equalTo(ADAPTATIONRATIO * 110.0f);
        }];
        
        [self.praiseBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.shareBtn);
            make.bottom.equalTo(self.commentBtn.mas_top).offset(-ADAPTATIONRATIO * 45.0f);
            make.height.mas_equalTo(ADAPTATIONRATIO * 110.0f);
        }];
        
        [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.equalTo(self.shareBtn);
            make.bottom.equalTo(self.praiseBtn.mas_top).offset(-ADAPTATIONRATIO * 70.0f);
            make.width.height.mas_equalTo(ADAPTATIONRATIO * 100.0f);
        }];
        
//        [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
//            make.center.equalTo(self);
//        }];
        
        [self.playBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self);
        }];
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(controlViewDidClick:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)setModel:(GKDYVideoModel *)model {
    _model = model;
    
    self.sliderView.value = 0;
    
    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.thumbnail_url] placeholderImage:[UIImage imageNamed:@"img_video_loading"]];
    
    self.nameLabel.text = [NSString stringWithFormat:@"@%@", model.author.name_show];
    
    if ([model.author.portrait containsString:@"http"]) {
         [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.author.portrait] placeholderImage:[UIImage imageNamed:@"placeholderimg"]];
    }else {
        self.iconView.image = [UIImage imageNamed:@"placeholderimg"];
    }
    
    self.contentLabel.text = model.title;
    
    self.praiseBtn.selected = model.isAgree;
    [self.praiseBtn setTitle:model.agree_num forState:UIControlStateNormal];
    [self.commentBtn setTitle:model.comment_num forState:UIControlStateNormal];
    [self.shareBtn setTitle:model.share_num forState:UIControlStateNormal];
}

#pragma mark - Public Methods
- (void)setProgress:(float)progress {
    self.sliderView.value = progress;
}

- (void)startLoading {
//    [self.loadingView startAnimating];
    [self.sliderView showLineLoading];
}

- (void)stopLoading {
//    [self.loadingView stopAnimating];
    [self.sliderView hideLineLoading];
}

- (void)showPlayBtn {
    self.playBtn.hidden = NO;
}

- (void)hidePlayBtn {
    self.playBtn.hidden = YES;
}

#pragma mark - Action
- (void)controlViewDidClick:(id)sender {
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

#pragma mark - 懒加载
- (UIImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [UIImageView new];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFit;
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

- (GKDYVideoItemButton *)praiseBtn {
    if (!_praiseBtn) {
        _praiseBtn = [GKDYVideoItemButton new];
        [_praiseBtn setImage:[UIImage imageNamed:@"icon_home_like_before"] forState:UIControlStateNormal];
        [_praiseBtn setImage:[UIImage imageNamed:@"icon_home_like_after"] forState:UIControlStateSelected];
        _praiseBtn.titleLabel.font = [UIFont systemFontOfSize:13.0f];
        [_praiseBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [_praiseBtn addTarget:self action:@selector(praiseBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _praiseBtn;
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

@end
