//
//  GKDYVideoPortraitCell.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/5/5.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoPortraitCell.h"

@interface GKDYVideoPortraitCell()<GKDYVideoPortraitViewDelegate, UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL isFullscreen;

@property (nonatomic, assign) BOOL isCodeSet;

@end

@implementation GKDYVideoPortraitCell

- (void)initUI {
    [self addSubview:self.scrollView];
    [self.scrollView addSubview:self.coverImgView];
    
//    [self addSubview:self.coverImgView];
    [self.coverImgView addSubview:self.portraitView];
    
    [self.scrollView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self);
    }];
    
//    [self.coverImgView mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.edges.equalTo(self);
//    }];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    self.coverImgView.frame = self.scrollView.bounds;
    self.portraitView.frame = self.coverImgView.bounds;
}

- (void)loadData:(GKDYVideoModel *)model {
    [super loadData:model];
    
    self.portraitView.model = model;
    
    if (self.manager) {
        [self.manager requestPlayUrlWithModel:model completion:nil];
    }
}

- (void)resetView {
    [super resetView];
    
    self.portraitView.slider.player = nil;
    self.portraitView.slider.sliderView.value = 0;
    self.portraitView.hidden = NO;
    self.portraitView.frame = self.coverImgView.bounds;
    [self.coverImgView addSubview:self.portraitView];
}

#pragma mark - UIScrollViewDelegate
- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return self.coverImgView;
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    self.coverImgView.center = [self centerOfScrollViewContent:scrollView];
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view {
    if (self.isCodeSet) return;
    if ([self.delegate respondsToSelector:@selector(videoCell:zoomBegan:)]) {
        [self.delegate videoCell:self zoomBegan:self.model];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale {
    if (self.isCodeSet) {
        self.isCodeSet = NO;
        return;
    }
    if ([self.delegate respondsToSelector:@selector(videoCell:zoomEnded:isFullscreen:)]) {
        BOOL isFullscreen = NO;
        if (scale > 1) {
            isFullscreen = YES;
            self.isFullscreen = isFullscreen;
        }else {
            self.isFullscreen = !self.isFullscreen;
            isFullscreen = self.isFullscreen;
        }
        [self.delegate videoCell:self zoomEnded:self.model isFullscreen:isFullscreen];
    }
    
    if (scale != 1) {
        self.isCodeSet = YES;
        [scrollView setZoomScale:1.0f animated:YES];
    }
}

- (CGPoint)centerOfScrollViewContent:(UIScrollView *)scrollView {
    CGFloat offsetX = (scrollView.bounds.size.width > scrollView.contentSize.width) ? (scrollView.bounds.size.width - scrollView.contentSize.width) * 0.5 : 0;
    CGFloat offsetY = (scrollView.bounds.size.height > scrollView.contentSize.height) ? (scrollView.bounds.size.height - scrollView.contentSize.height) * 0.5 : 0;
    CGPoint actualCenter = CGPointMake(scrollView.contentSize.width * 0.5 + offsetX, scrollView.contentSize.height * 0.5 + offsetY);
    return actualCenter;
}

- (void)closeFullscreen {
    self.isFullscreen = NO;
    if ([self.delegate respondsToSelector:@selector(videoCell:zoomEnded:isFullscreen:)]) {
        [self.delegate videoCell:self zoomEnded:self.model isFullscreen:self.isFullscreen];
    }
}

#pragma mark - GKDYVideoPortraitViewDelegate
- (void)didClickIcon:(GKDYVideoModel *)model {
    if ([self.delegate respondsToSelector:@selector(videoCell:didClickIcon:)]) {
        [self.delegate videoCell:self didClickIcon:model];
    }
}

- (void)didClickLike:(GKDYVideoModel *)model {
    if ([self.delegate respondsToSelector:@selector(videoCell:didClickLike:)]) {
        [self.delegate videoCell:self didClickLike:model];
    }
}

- (void)didClickComment:(GKDYVideoModel *)model {
    if ([self.delegate respondsToSelector:@selector(videoCell:didClickComment:)]) {
        [self.delegate videoCell:self didClickComment:model];
    }
}

- (void)didClickShare:(GKDYVideoModel *)model {
    if ([self.delegate respondsToSelector:@selector(videoCell:didClickShare:)]) {
        [self.delegate videoCell:self didClickShare:model];
    }
}

- (void)didClickDanmu:(GKDYVideoModel *)model {
    if ([self.delegate respondsToSelector:@selector(videoCell:didClickDanmu:)]) {
        [self.delegate videoCell:self didClickDanmu:model];
    }
}

- (void)didClickFullscreen:(GKDYVideoModel *)model {
    if ([self.delegate respondsToSelector:@selector(videoCell:didClickFullscreen:)]) {
        [self.delegate videoCell:self didClickFullscreen:model];
    }
}

#pragma mark - Lazy
- (UIScrollView *)scrollView {
    if (!_scrollView) {
        _scrollView = [[UIScrollView alloc] init];
        _scrollView.delegate = self;
        _scrollView.backgroundColor = UIColor.clearColor;
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        _scrollView.showsVerticalScrollIndicator = NO;
        _scrollView.showsHorizontalScrollIndicator = NO;
        _scrollView.minimumZoomScale = 1.0f;
        _scrollView.maximumZoomScale = 10.0f;
    }
    return _scrollView;
}

- (GKDYVideoPortraitView *)portraitView {
    if (!_portraitView) {
        _portraitView = [[GKDYVideoPortraitView alloc] initWithFrame:UIScreen.mainScreen.bounds];
        _portraitView.delegate = self;
    }
    return _portraitView;
}

@end
