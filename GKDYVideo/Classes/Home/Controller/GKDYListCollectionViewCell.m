//
//  GKDYListCollectionViewCell.m
//  GKDYVideo
//
//  Created by gaokun on 2018/12/14.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYListCollectionViewCell.h"

@interface GKDYListCollectionViewCell()

@property (nonatomic, strong) UIButton      *starBtn;

@end

@implementation GKDYListCollectionViewCell

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

- (void)setModel:(GKAWEModel *)model {
    _model = model;
    
    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.video.cover.url_list.firstObject]];
    
    [self.starBtn setTitle:model.statistics.digg_count forState:UIControlStateNormal];
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

- (UIButton *)starBtn {
    if (!_starBtn) {
        _starBtn = [UIButton new];
        [_starBtn setImage:[UIImage imageNamed:@"ss_icon_like"] forState:UIControlStateNormal];
        _starBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [_starBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
    return _starBtn;
}

@end
