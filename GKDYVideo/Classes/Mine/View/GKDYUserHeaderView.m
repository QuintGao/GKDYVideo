//
//  GKDYUserHeaderView.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYUserHeaderView.h"

@interface GKDYUserHeaderView()

@property (nonatomic, strong) UIImageView *bgImgView;
@property (nonatomic, assign) CGRect bgImgFrame;

@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIImageView *iconView;
@property (nonatomic, strong) UILabel *nameLabel;
@property (nonatomic, strong) UILabel *dyIdLabel;

@end

@implementation GKDYUserHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self initUI];
        self.bgImgView.frame = CGRectMake(0, 0, frame.size.width, kDYUserHeaderBgHeight);
        self.bgImgFrame = self.bgImgView.frame;
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.bgImgView];
    [self addSubview:self.contentView];
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.dyIdLabel];
    
    [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self).insets(UIEdgeInsetsMake(kDYUserHeaderBgHeight, 0, 0, 0));
    }];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.contentView).offset(15);
        make.top.equalTo(self.contentView).offset(-15);
        make.width.height.mas_equalTo(96);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.iconView);
        make.top.equalTo(self.iconView.mas_bottom).offset(20);
    }];
    
    [self.dyIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.nameLabel);
        make.top.equalTo(self.nameLabel.mas_bottom).offset(10);
    }];
}

- (void)setModel:(GKDYUserModel *)model {
    _model = model;
    
    self.nameLabel.text = model.author;
    
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.author_icon]];
    
    self.dyIdLabel.text = [NSString stringWithFormat:@"%@ %@", model.fansCntText, model.videoCntText];
}

- (void)scrollViewDidScroll:(CGFloat)offsetY {
    CGRect frame = self.bgImgFrame;
    // 上下放大
    frame.size.height -= offsetY;
    frame.origin.y = offsetY;
    
    // 左右放大
    if (offsetY <= 0) {
        frame.size.width = frame.size.height * self.bgImgFrame.size.width / self.bgImgFrame.size.height;
        frame.origin.x   = (self.frame.size.width - frame.size.width) / 2;
    }
    
    self.bgImgView.frame = frame;
}

#pragma mark - 懒加载
- (UIImageView *)bgImgView {
    if (!_bgImgView) {
        _bgImgView = [UIImageView new];
        _bgImgView.image = [UIImage imageNamed:@"bg"];
        _bgImgView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImgView.clipsToBounds = YES;
    }
    return _bgImgView;
}

- (UIView *)contentView {
    if (!_contentView) {
        _contentView = [UIView new];
        _contentView.backgroundColor = GKColorRGB(34, 33, 37);
    }
    return _contentView;
}

- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [UIImageView new];
        _iconView.image = [UIImage imageNamed:@"dy_icon"];
        _iconView.layer.cornerRadius = 48.0f;
        _iconView.layer.masksToBounds = YES;
        _iconView.layer.borderColor = GKColorRGB(34, 33, 37).CGColor;
        _iconView.layer.borderWidth = 3;
    }
    return _iconView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [UILabel new];
        _nameLabel.textColor = [UIColor whiteColor];
        _nameLabel.font = [UIFont systemFontOfSize:16.0f];
    }
    return _nameLabel;
}

- (UILabel *)dyIdLabel {
    if (!_dyIdLabel) {
        _dyIdLabel = [UILabel new];
        _dyIdLabel.textColor = [UIColor whiteColor];
        _dyIdLabel.font = [UIFont systemFontOfSize:14.0f];
    }
    return _dyIdLabel;
}

@end
