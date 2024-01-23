//
//  GKDYTitleView.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYTitleView.h"
#import "GKBallLoadingView.h"

#define kTransitionCenter 20.0f

@interface GKDYTitleView()

@property (nonatomic, strong) UILabel *refreshLabel;

@property (nonatomic, strong) UIButton *searchBtn;

@property (nonatomic, strong) GKBallLoadingView *loadingView;

@property (nonatomic, assign) BOOL isRefreshing;

@end

@implementation GKDYTitleView

- (instancetype)init {
    if (self = [super init]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.categoryView];
    [self addSubview:self.searchBtn];
    [self addSubview:self.refreshLabel];
    [self addSubview:self.loadingView];
    
    [self.categoryView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.left.equalTo(self).offset(60);
        make.right.equalTo(self).offset(-60);
    }];
    
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.top.bottom.equalTo(self);
    }];
    
    [self.refreshLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.bottom.equalTo(self);
        make.centerX.equalTo(self);
    }];
    
    [self.loadingView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
        make.centerY.equalTo(self);
        make.width.height.mas_equalTo(44);
    }];
}

- (void)changeAlphaWithDistance:(CGFloat)distance isEnd:(BOOL)isEnd {
    if (isEnd) {
        [UIView animateWithDuration:0.25 animations:^{
            [self changeFrameWithDistance:0];
            self.categoryView.alpha = 1;
            self.refreshLabel.alpha = 0;
            self.loadingView.alpha = 1;
        }];
        
        if (distance >= 2 * kTransitionCenter) {
            self.searchBtn.alpha = 0;
            self.isRefreshing = YES;
            [self.loadingView startLoading];
            !self.loadingBlock ?: self.loadingBlock();
        }else {
            self.searchBtn.alpha = 1;
            self.loadingView.alpha = 0;
        }
    }else {
        if (distance <= 0) {
            self.categoryView.alpha = 1;
            self.searchBtn.alpha = 1;
            self.refreshLabel.alpha = 0;
            self.loadingView.alpha = 0;
        }else if (distance > 0 && distance < kTransitionCenter) {
            CGFloat alpha = distance / kTransitionCenter;
            self.categoryView.alpha = 1 - alpha;
            self.searchBtn.alpha = 1 - alpha;
            self.refreshLabel.alpha = 0;
            self.loadingView.alpha = 0;
            
            // 改变位置
            [self changeFrameWithDistance:distance];
        }else if (distance >= kTransitionCenter && distance <= 2 * kTransitionCenter) {
            CGFloat alpha = (2 * kTransitionCenter - distance) / kTransitionCenter;
            self.categoryView.alpha = 0;
            self.searchBtn.alpha = 0;
            self.refreshLabel.alpha = 1 - alpha;
            self.loadingView.alpha = 1 - alpha;
            
            // 改变位置
            [self changeFrameWithDistance:distance];
            
            [self.loadingView startLoadingWithProgress:1 - alpha];
        }else {
            self.categoryView.alpha = 0;
            self.searchBtn.alpha = 0;
            self.refreshLabel.alpha = 1;
            self.loadingView.alpha = 1;
            
            [self.loadingView startLoadingWithProgress:1];
        }
    }
}

- (void)changeFrameWithDistance:(CGFloat)distance {
    CGRect frame = self.categoryView.frame;
    frame.origin.y = distance;
    self.categoryView.frame = frame;
    
    frame = self.searchBtn.frame;
    frame.origin.y = distance;
    self.searchBtn.frame = frame;
    
    frame = self.refreshLabel.frame;
    frame.origin.y = distance;
    self.refreshLabel.frame = frame;
    
    frame = self.loadingView.frame;
    frame.origin.y = distance;
    self.loadingView.frame = frame;
}

- (void)loadingEnd {
    self.searchBtn.alpha = 1;
    self.loadingView.alpha = 0;
    [self.loadingView stopLoading];
    self.isRefreshing = NO;
}

- (void)searchClick:(id)sender {
    
}

#pragma mark - Lazy
- (JXCategoryTitleView *)categoryView {
    if (!_categoryView) {
        _categoryView = [[JXCategoryTitleView alloc] init];
        _categoryView.backgroundColor = UIColor.clearColor;
        _categoryView.titleColor = UIColor.lightGrayColor;
        _categoryView.titleSelectedColor = UIColor.whiteColor;
        _categoryView.titleFont = [UIFont systemFontOfSize:16];
        _categoryView.titleSelectedFont = [UIFont boldSystemFontOfSize:16];
        _categoryView.cellSpacing = 10;
        
        JXCategoryIndicatorLineView *lineView = [[JXCategoryIndicatorLineView alloc] init];
        lineView.indicatorColor = UIColor.whiteColor;
        lineView.indicatorWidthIncrement = -4;
        _categoryView.indicators = @[lineView];
    }
    return _categoryView;
}

- (UIButton *)searchBtn {
    if (!_searchBtn) {
        _searchBtn = [[UIButton alloc] init];
        [_searchBtn setImage:[UIImage imageNamed:@"ich_feed_search_Normal"] forState:UIControlStateNormal];
        [_searchBtn addTarget:self action:@selector(searchClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchBtn;
}

- (UILabel *)refreshLabel {
    if (!_refreshLabel) {
        _refreshLabel = [[UILabel alloc] init];
        _refreshLabel.font = [UIFont systemFontOfSize:16];
        _refreshLabel.textColor = UIColor.whiteColor;
        _refreshLabel.text = @"下拉刷新内容";
        _refreshLabel.alpha = 0;
    }
    return _refreshLabel;
}

- (GKBallLoadingView *)loadingView {
    if (!_loadingView) {
        _loadingView = [[GKBallLoadingView alloc] init];
        _loadingView.alpha = 0;
    }
    return _loadingView;
}

@end
