//
//  GKDYVideoLandscapeCell.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/5/5.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoLandscapeCell.h"
#import "GKDYVideoMaskView.h"
#import "UIButton+GKCategory.h"

@interface GKDYVideoLandscapeCell()

@property (nonatomic, strong) GKDYVideoMaskView *topContainerView;

@property (nonatomic, strong) UIButton *backBtn;

@property (nonatomic, strong) UILabel *titleLabel;

@end

@implementation GKDYVideoLandscapeCell

- (void)initUI {
    [super initUI];
    
    [self addSubview:self.topContainerView];
    [self.topContainerView addSubview:self.backBtn];
    [self.topContainerView addSubview:self.titleLabel];
    
    [self.topContainerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self);
        make.height.mas_equalTo(80);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(25);
        make.left.equalTo(self.topContainerView.mas_safeAreaLayoutGuideLeft).offset(12);
    }];
    
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.backBtn).offset(3);
        make.left.equalTo(self.backBtn.mas_right).offset(5);
        make.right.equalTo(self.topContainerView.mas_safeAreaLayoutGuideRight).offset(-30);
    }];
    
    self.topContainerView.hidden = YES;
    self.isShowTop = NO;
}

- (void)loadData:(GKDYVideoModel *)model {
    [super loadData:model];
    
    self.titleLabel.text = model.title;
}

- (void)hideTopView {
    self.topContainerView.hidden = YES;
    self.isShowTop = NO;
}

- (void)showTopView {
    self.topContainerView.hidden = NO;
    self.isShowTop = YES;
}

- (void)autoHide {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideTopView) object:nil];
    [self performSelector:@selector(hideTopView) withObject:nil afterDelay:3.0f];
}

- (void)resetView {
    [super resetView];
    [self showTopView];
}

- (void)backAction {
    !self.backClickBlock ?: self.backClickBlock();
}

#pragma mark - Lazy
- (GKDYVideoMaskView *)topContainerView {
    if (!_topContainerView) {
        _topContainerView = [[GKDYVideoMaskView alloc] initWithStyle:GKDYVideoMaskViewStyle_Top];
    }
    return _topContainerView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [[UIButton alloc] init];
        [_backBtn setEnlargeEdge:10];
        [_backBtn setImage:[UIImage imageNamed:@"ic_back_white"] forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont boldSystemFontOfSize:15];
        _titleLabel.textColor = UIColor.whiteColor;
        _titleLabel.numberOfLines = 0;
    }
    return _titleLabel;
}

@end
