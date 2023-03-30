//
//  GKDYVideoListCell.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoListCell.h"

@interface GKDYVideoListCell()

@property (nonatomic, strong) UIButton      *starBtn;

@end

@implementation GKDYVideoListCell

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self.contentView addSubview:self.coverImgView];
        [self.contentView addSubview:self.starBtn];
        
        [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self.contentView);
        }];
        
        [self.starBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(12.0f);
            make.bottom.equalTo(self.contentView).offset(-12.0f);
        }];
    }
    return self;
}

- (void)setModel:(GKDYUserVideoModel *)model {
    _model = model;
    
    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.cover_src]];
    
    [self.starBtn setTitle:model.playcntText forState:UIControlStateNormal];
}

#pragma mark - 懒加载
- (SDAnimatedImageView *)coverImgView {
    if (!_coverImgView) {
        _coverImgView = [SDAnimatedImageView new];
        _coverImgView.contentMode = UIViewContentModeScaleAspectFill;
        _coverImgView.clipsToBounds = YES;
    }
    return _coverImgView;
}

- (UIButton *)starBtn {
    if (!_starBtn) {
        _starBtn = [UIButton new];
        [_starBtn setImage:[UIImage imageNamed:@"ss_icon_like"] forState:UIControlStateNormal];
        _starBtn.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_starBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _starBtn;
}

@end
