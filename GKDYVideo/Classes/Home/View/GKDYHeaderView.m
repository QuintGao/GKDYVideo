//
//  GKDYHeaderView.m
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYHeaderView.h"

@interface GKDYHeaderView()

@property (nonatomic, assign) CGRect        bgImgFrame;
@property (nonatomic, strong) UIImageView   *bgImgView;

@property (nonatomic, strong) UIView        *contentView;
@property (nonatomic, strong) UIImageView   *iconImgView;
@property (nonatomic, strong) UILabel       *nameLabel;
@property (nonatomic, strong) UILabel       *dyIdLabel;

@end

@implementation GKDYHeaderView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.bgImgView];
        
        [self addSubview:self.contentView];
        [self.contentView addSubview:self.iconImgView];
        [self.contentView addSubview:self.nameLabel];
        [self.contentView addSubview:self.dyIdLabel];
        
        self.bgImgFrame = CGRectMake(0, 0, frame.size.width, kDYBgImgHeight);
        self.bgImgView.frame = self.bgImgFrame;
        
        [self.contentView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self).insets(UIEdgeInsetsMake(kDYBgImgHeight, 0, 0, 0));
        }];
        
        [self.iconImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10.0f);
            make.top.equalTo(self.contentView).offset(-15.0f);
            make.width.height.mas_equalTo(96.0f);
        }];
        
        [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(10.0f);
            make.top.equalTo(self.iconImgView.mas_bottom).offset(20.0f);
        }];
        
        [self.dyIdLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.nameLabel);
            make.top.equalTo(self.nameLabel.mas_bottom).offset(10.0f);
        }];
    }
    return self;
}

- (void)setModel:(GKAWEModel *)model {
    _model = model;
    
    self.nameLabel.text = model.author.nickname;
    
    self.dyIdLabel.text = [NSString stringWithFormat:@"ID号：%@", model.author.uid];
    
    [self.iconImgView sd_setImageWithURL:[NSURL URLWithString:model.author.avatar_medium.url_list.firstObject] placeholderImage:[UIImage imageNamed:@"placeholderimg"]];
}

- (void)scrollViewDidScroll:(CGFloat)offsetY {
    NSLog(@"%f", offsetY);
    
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

- (UIImageView *)iconImgView {
    if (!_iconImgView) {
        _iconImgView = [UIImageView new];
        _iconImgView.image = [UIImage imageNamed:@"dy_icon"];
        _iconImgView.layer.cornerRadius = 48.0f;
        _iconImgView.layer.masksToBounds = YES;
        _iconImgView.layer.borderColor = GKColorRGB(34, 33, 37).CGColor;
        _iconImgView.layer.borderWidth = 3;
    }
    return _iconImgView;
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
