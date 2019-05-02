//
//  GKSlidePopupView.m
//  GKDYVideo
//
//  Created by QuintGao on 2019/4/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKSlidePopupView.h"

@interface GKSlidePopupView()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIView    *contentView;

@property (nonatomic, strong) UITapGestureRecognizer    *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer    *panGesture;

@property (nonatomic, weak) UIScrollView                *scrollView;
@property (nonatomic, assign) BOOL                      isDragScrollView;
@property (nonatomic, assign) CGFloat                   lastDragDistance;

@end

@implementation GKSlidePopupView

+ (instancetype)popupViewWithFrame:(CGRect)frame contentView:(UIView *)contentView {
    return [[GKSlidePopupView alloc] initWithFrame:frame contentView:contentView];
}

- (instancetype)initWithFrame:(CGRect)frame contentView:(UIView *)contentView {
    if (self = [super initWithFrame:frame]) {
        self.contentView = contentView;
        
        CGRect contentFrame = contentView.frame;
        contentFrame.origin.y = frame.size.height;
        self.contentView.frame = contentFrame;
        [self addSubview:self.contentView];
        
        // 添加手势
        [self addGestureRecognizer:self.tapGesture];
        [self addGestureRecognizer:self.panGesture];
    }
    return self;
}

- (void)showFrom:(UIView *)fromView {
    [fromView addSubview:self];
    
    [self show];
}

- (void)show {
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.y = self.frame.size.height - frame.size.height;
        self.contentView.frame = frame;
    } completion:^(BOOL finished) {
        
    }];
}

- (void)dismiss {
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.y = self.frame.size.height;
        self.contentView.frame = frame;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.panGesture) {
        UIView *touchView = touch.view;
        while (touchView != nil) {
            if ([touchView isKindOfClass:[UIScrollView class]]) {
                self.scrollView = (UIScrollView *)touchView;
                self.isDragScrollView = YES;
                break;
            }else if (touchView == self.contentView) {
                self.isDragScrollView = NO;
                break;
            }
            touchView = (UIView *)[touchView nextResponder];
        }
    }
    return YES;
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    if (gestureRecognizer == self.tapGesture) {
        CGPoint point = [gestureRecognizer locationInView:self.contentView];
        if ([self.contentView.layer containsPoint:point] && gestureRecognizer.view == self) {
            return NO;
        }
    }else if (gestureRecognizer == self.panGesture) {
        return YES;
    }
    return YES;
}

// 是否与其他手势共存
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.panGesture) {
        if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] || [otherGestureRecognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
            if ([otherGestureRecognizer.view isKindOfClass:[UIScrollView class]]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - HandleGesture
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    CGPoint point = [tapGesture locationInView:self.contentView];
    if (![self.contentView.layer containsPoint:point] && tapGesture.view == self) {
        [self dismiss];
    }
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:self.contentView];
    if (self.isDragScrollView) {
        if (self.scrollView.contentOffset.y <= 0) { // UIScrollView未滑动
            if (translation.y > 0) { // 向下拖拽
                self.scrollView.contentOffset = CGPointZero;
                self.scrollView.panGestureRecognizer.enabled = NO;
                self.isDragScrollView = NO;
                
                CGRect contentFrame = self.contentView.frame;
                contentFrame.origin.y += translation.y;
                self.contentView.frame = contentFrame;
            }
        }
    }else {
        CGFloat contentM = (self.frame.size.height - self.contentView.frame.size.height);
        
        if (translation.y > 0) { // 向下拖拽
            CGRect contentFrame = self.contentView.frame;
            contentFrame.origin.y += translation.y;
            self.contentView.frame = contentFrame;
        }else if (translation.y < 0 && self.contentView.frame.origin.y > contentM) { // 向上拖拽
            CGRect contentFrame = self.contentView.frame;
            contentFrame.origin.y = MAX((self.contentView.frame.origin.y + translation.y), contentM);
            self.contentView.frame = contentFrame;
        }
    }
    
    [panGesture setTranslation:CGPointZero inView:self.contentView];
    
    if (panGesture.state == UIGestureRecognizerStateEnded) {
        CGPoint velocity = [panGesture velocityInView:self.contentView];
        
        self.scrollView.panGestureRecognizer.enabled = YES;
        
        // 结束时的速度>0 滑动距离> 5 且UIScrollView滑动到最顶部
        if (velocity.y > 0 && self.lastDragDistance > 5 && !self.isDragScrollView) {
            [self dismiss];
        }else {
            [self show];
        }
    }
    
    self.lastDragDistance = translation.y;
}

#pragma mark - 懒加载
- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        _tapGesture.delegate = self;
    }
    return _tapGesture;
}

- (UIPanGestureRecognizer *)panGesture {
    if (!_panGesture) {
        _panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _panGesture.delegate = self;
    }
    return _panGesture;
}

@end
