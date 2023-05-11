//
//  GKDYVideoCell.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoCell.h"

@interface GKDYVideoCell()

@end

@implementation GKDYVideoCell

- (instancetype)initWithReuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithReuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.coverImgView];
    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
}

- (void)loadData:(GKDYVideoModel *)model {
    self.model = model;
    
    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.poster_small]];
}

- (void)setModel:(GKDYVideoModel *)model {
    _model = model;
    
    [self.coverImgView sd_setImageWithURL:[NSURL URLWithString:model.poster_small]];
    
}

- (void)resetView {
    
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

@end
