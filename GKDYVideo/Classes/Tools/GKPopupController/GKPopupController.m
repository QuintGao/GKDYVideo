//
//  GKPopupController.m
//  GKPopupController
//
//  Created by QuintGao on 2024/1/12.
//

#import "GKPopupController.h"

typedef NS_ENUM(NSUInteger, GKPopupPanGestureDirection) {
    GKPopupPanGestureDirectionHorizontal,   // 水平方向
    GKPopupPanGestureDirectionVelocity      // 竖直方向
};

int const static kPopupPanTranslationThreshold = 5;

@interface GKPopupPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, assign) GKPopupPanGestureDirection direction;

@end

@implementation GKPopupPanGestureRecognizer {
    BOOL _isDrag;
    int _moveX;
    int _moveY;
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _moveX += prevPoint.x - nowPoint.x;
    _moveY += prevPoint.y - nowPoint.y;
    if (!_isDrag) {
        if (abs(_moveX) > kPopupPanTranslationThreshold) {
            if (self.direction == GKPopupPanGestureDirectionVelocity) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _isDrag = YES;
            }
        }else if (abs(_moveY) > kPopupPanTranslationThreshold) {
            if (self.direction == GKPopupPanGestureDirectionHorizontal) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _isDrag = YES;
            }
        }
    }
}

- (void)reset {
    [super reset];
    _isDrag = NO;
    _moveX = 0;
    _moveY = 0;
}

@end

@interface GKPopupController ()<UIGestureRecognizerDelegate>

@property (nonatomic, strong) UIWindow *alertWindow;

@property (nonatomic, strong) UIView *backgroundView;

@property (nonatomic, weak) UIView *contentView;

@property (nonatomic, assign) CGFloat contentHeight;

@property (nonatomic, weak) UIScrollView *scrollView;

@property (nonatomic, assign) BOOL isDragScrollView;

@property (nonatomic, assign) CGPoint beginTranslation;

@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;

@property (nonatomic, strong) GKPopupPanGestureRecognizer *horizontalPanGesture;

@property (nonatomic, strong) GKPopupPanGestureRecognizer *velocityPanGesture;

@end

@implementation GKPopupController

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
}

#pragma mark - Public
- (void)show {
    [self initUI];
    [self alertWindow];
    [self showWithCompletion:nil];
}

- (void)dismiss {
    [self dismissWithCompletion:nil];
}

- (void)refreshContentHeight {
    self.contentHeight = [self.delegate contentHeight];
    if ([self.delegate respondsToSelector:@selector(refreshContentViewAnimation)]) {
        [self.delegate refreshContentViewAnimation];
    }
//    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
//        CGRect frame = self.contentView.frame;
//        frame.origin.y = CGRectGetHeight(self.view.frame) - self.contentHeight;
//        frame.size.height = self.contentHeight;
//        self.contentView.frame = frame;
//        if ([self.delegate respondsToSelector:@selector(refreshContentViewAnimation)]) {
//            [self.delegate refreshContentViewAnimation];
//        }
//    } completion:^(BOOL finished) {
//        
//    }];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    if (gestureRecognizer == self.horizontalPanGesture || gestureRecognizer == self.velocityPanGesture) {
        UIView *touchView = touch.view;
        while (touchView != nil) {
            if ([touchView isKindOfClass:UIScrollView.class]) {
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
    CGPoint point = [gestureRecognizer locationInView:self.contentView];
    if (gestureRecognizer == self.tapGesture) {
        if ([self.contentView.layer containsPoint:point] && gestureRecognizer.view == self.view) {
            return NO;
        }
    }else if (gestureRecognizer == self.horizontalPanGesture || gestureRecognizer == self.velocityPanGesture) {
        if (![self.contentView.layer containsPoint:point] && gestureRecognizer.view == self.view) {
            return NO;
        }
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    if (gestureRecognizer == self.horizontalPanGesture || gestureRecognizer == self.velocityPanGesture) {
        if ([otherGestureRecognizer isKindOfClass:NSClassFromString(@"UIScrollViewPanGestureRecognizer")] || [otherGestureRecognizer isKindOfClass:UIPanGestureRecognizer.class]) {
            if ([otherGestureRecognizer.view isKindOfClass:UIScrollView.class]) {
                return YES;
            }
        }
    }
    return NO;
}

#pragma mark - Gesture Handle
- (void)handleTapGesture:(UITapGestureRecognizer *)tapGesture {
    CGPoint point = [tapGesture locationInView:self.contentView];
    if (![self.contentView.layer containsPoint:point] && tapGesture.view == self.view) {
        [self dismiss];
    }
}

- (void)handlePanGesture:(GKPopupPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture locationInView:panGesture.view];
    CGPoint velocity = [panGesture velocityInView:panGesture.view];
    // 最小Y值
    CGFloat minY = CGRectGetHeight(self.view.frame) - self.contentHeight;
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.beginTranslation = translation;
            // 横向滑动时，禁止UIScrollView滑动
            if (panGesture.direction == GKPopupPanGestureDirectionHorizontal) {
                self.scrollView.panGestureRecognizer.enabled = NO;
            }
            if ([self.delegate respondsToSelector:@selector(panSlideBegan)]) {
                [self.delegate panSlideBegan];
            }
        }
            break;
        case UIGestureRecognizerStateChanged: {
            if (panGesture.direction == GKPopupPanGestureDirectionHorizontal) { // 横向滑动
                // 滑动百分比
                CGFloat ratio = (translation.x - self.beginTranslation.x) / CGRectGetWidth(self.view.frame);
                // 转换为Y值
                CGFloat scrollY = minY + self.contentHeight * ratio;
                // 更新frame
                [self updateContentViewFrameY:scrollY];
                if ([self.delegate respondsToSelector:@selector(panSlideChangeWithRatio:)]) {
                    [self.delegate panSlideChangeWithRatio:ratio];
                }
            }else { // 纵向滑动
                CGFloat scrollY = minY + (translation.y - self.beginTranslation.y);
                CGFloat ratio = (translation.y - self.beginTranslation.y) / self.contentHeight;
                if (self.isDragScrollView) { // 拖拽scrollView
                    // 当UIScrollView在最顶端时，处理视图的滑动
                    if (self.scrollView.contentOffset.y <= 0 && translation.y > 0) {
                        self.scrollView.contentOffset = CGPointZero;
                        self.scrollView.panGestureRecognizer.enabled = NO;
                        self.isDragScrollView = NO;
                        self.beginTranslation = translation;
//                        [self updateContentViewFrameY:scrollY];
                        if ([self.delegate respondsToSelector:@selector(panSlideChangeWithRatio:)]) {
                            [self.delegate panSlideChangeWithRatio:ratio];
                        }
                    }
                }else {
                    [self updateContentViewFrameY:scrollY];
                    if ([self.delegate respondsToSelector:@selector(panSlideChangeWithRatio:)]) {
                        [self.delegate panSlideChangeWithRatio:ratio];
                    }
                }
            }
            // 背景透明度
            CGFloat alpha = (CGRectGetHeight(self.view.frame) - CGRectGetMinY(self.contentView.frame)) / self.contentHeight;
            self.backgroundView.alpha = alpha;
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            // 平移距离
            CGFloat translationY = CGRectGetMinY(self.contentView.frame) - minY;
            if (panGesture.direction == GKPopupPanGestureDirectionHorizontal) {
                if (velocity.x > self.velocityThreshold || translationY > self.translationThreshold) {
                    [self dismissWithCompletion:nil];
                    if ([self.delegate respondsToSelector:@selector(panSlideEnded:)]) {
                        [self.delegate panSlideEnded:NO];
                    }
                }else {
                    [self showWithCompletion:nil];
                    if ([self.delegate respondsToSelector:@selector(panSlideEnded:)]) {
                        [self.delegate panSlideEnded:YES];
                    }
                }
            }else {
                if (velocity.y > self.velocityThreshold || translationY > self.translationThreshold) {
                    [self dismissWithCompletion:nil];
                    if ([self.delegate respondsToSelector:@selector(panSlideEnded:)]) {
                        [self.delegate panSlideEnded:NO];
                    }
                }else {
                    [self showWithCompletion:nil];
                    if ([self.delegate respondsToSelector:@selector(panSlideEnded:)]) {
                        [self.delegate panSlideEnded:YES];
                    }
                }
            }
            self.scrollView.panGestureRecognizer.enabled = YES;
        }
            break;
        default:
            break;
    }
}

#pragma mark - Private
- (void)initUI {
    self.delegate.popupController = self;
    
    self.contentView = [self.delegate contentView];
    self.contentHeight = [self.delegate contentHeight];
    
    CGRect frame = self.view.bounds;
    self.backgroundView.frame = frame;
    [self.view addSubview:self.backgroundView];
    
    frame.origin.y = frame.size.height;
    frame.size.height = self.contentHeight;
    self.contentView.frame = frame;
    [self.view addSubview:self.contentView];
    
    BOOL allowsTap = YES;
    if ([self.delegate respondsToSelector:@selector(allowsTapBackgroundToDismiss)]) {
        allowsTap = [self.delegate allowsTapBackgroundToDismiss];
    }
    if (allowsTap) {
        [self.view addGestureRecognizer:self.tapGesture];
    }
    BOOL allowsSlide = YES;
    if ([self.delegate respondsToSelector:@selector(allowsSlideToDismiss)]) {
        allowsSlide = [self.delegate allowsSlideToDismiss];
    }
    if (allowsSlide) {
        [self.view addGestureRecognizer:self.velocityPanGesture];
        BOOL allowRightSlide = YES;
        if ([self.delegate respondsToSelector:@selector(allowsRightSlideToDismiss)]) {
            allowRightSlide = [self.delegate allowsRightSlideToDismiss];
        }
        if (allowRightSlide) {
            [self.view addGestureRecognizer:self.horizontalPanGesture];
        }
    }
}

- (void)showWithCompletion:(void(^)(void))completion {
    if ([self.delegate respondsToSelector:@selector(contentViewWillShow)]) {
        [self.delegate contentViewWillShow];
    }
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.y = self.view.frame.size.height - self.contentHeight;
        self.contentView.frame = frame;
        self.backgroundView.alpha = 1;
        if ([self.delegate respondsToSelector:@selector(contentViewShowAnimation)]) {
            [self.delegate contentViewShowAnimation];
        }
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(contentViewDidShow)]) {
            [self.delegate contentViewDidShow];
        }
        !completion ?: completion();
    }];
}

- (void)dismissWithCompletion:(void(^)(void))completion {
    if ([self.delegate respondsToSelector:@selector(contentViewWillDismiss)]) {
        [self.delegate contentViewWillDismiss];
    }
    [UIView animateWithDuration:self.animationDuration delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
        CGRect frame = self.contentView.frame;
        frame.origin.y = self.view.frame.size.height;
        self.contentView.frame = frame;
        self.backgroundView.alpha = 0;
        if ([self.delegate respondsToSelector:@selector(contentViewDismissAnimation)]) {
            [self.delegate contentViewDismissAnimation];
        }
    } completion:^(BOOL finished) {
        if ([self.delegate respondsToSelector:@selector(contentViewDidDismiss)]) {
            [self.delegate contentViewDidDismiss];
        }
        self.alertWindow.hidden = YES;
        self.alertWindow.rootViewController = nil;
        !completion ?: completion();
    }];
}

- (NSTimeInterval)animationDuration {
    NSTimeInterval duration = 0.25;
    if ([self.delegate respondsToSelector:@selector(animationDuration)]) {
        duration = [self.delegate animationDuration];
    }
    return duration;
}

- (void)updateContentViewFrameY:(CGFloat)y {
    CGFloat minY = CGRectGetHeight(self.view.frame) - self.contentHeight;
    CGRect frame = self.contentView.frame;
    frame.origin.y = MAX(minY, y);
    self.contentView.frame = frame;
}

- (CGFloat)velocityThreshold {
    CGFloat velocity = 300;
    if ([self.delegate respondsToSelector:@selector(velocityThreshold)]) {
        velocity = [self.delegate velocityThreshold];
    }
    return velocity;
}

- (CGFloat)translationThreshold {
    CGFloat translation = self.contentHeight / 2;
    if ([self.delegate respondsToSelector:@selector(translationThreshold)]) {
        translation = [self.delegate translationThreshold];
    }
    return translation;
}

#pragma mark - Lazy
- (UIWindow *)alertWindow {
    if (!_alertWindow) {
        if (@available(iOS 13.0, *)) {
            UIScene *scene = [UIApplication sharedApplication].connectedScenes.allObjects.firstObject;
            if (scene && [scene isKindOfClass:UIWindowScene.class]) {
                _alertWindow = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
            }
        }
        if (!_alertWindow) {
            _alertWindow = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
        }
        _alertWindow.windowLevel = UIWindowLevelStatusBar;
        _alertWindow.backgroundColor = UIColor.clearColor;
        _alertWindow.hidden = NO;
        
        BOOL needAddNav = YES;
        if ([self.delegate respondsToSelector:@selector(needAddNavigationController)]) {
            needAddNav = [self.delegate needAddNavigationController];
        }
        if (needAddNav) {
            UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:self];
            nav.view.backgroundColor = UIColor.clearColor;
            _alertWindow.rootViewController = nav;
        }else {
            _alertWindow.rootViewController = self;
        }
    }
    return _alertWindow;
}

- (UIView *)backgroundView {
    if (!_backgroundView) {
        _backgroundView = [[UIView alloc] init];
        if ([self.delegate respondsToSelector:@selector(backColor)]) {
            _backgroundView.backgroundColor = [self.delegate backColor];
        }else {
            _backgroundView.backgroundColor = [UIColor.blackColor colorWithAlphaComponent:0.5];
        }
        _backgroundView.alpha = 0;
    }
    return _backgroundView;
}

- (UITapGestureRecognizer *)tapGesture {
    if (!_tapGesture) {
        _tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        _tapGesture.delegate = self;
    }
    return _tapGesture;
}

- (GKPopupPanGestureRecognizer *)horizontalPanGesture {
    if (!_horizontalPanGesture) {
        _horizontalPanGesture = [[GKPopupPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _horizontalPanGesture.delegate = self;
        _horizontalPanGesture.direction = GKPopupPanGestureDirectionHorizontal;
    }
    return _horizontalPanGesture;
}

- (GKPopupPanGestureRecognizer *)velocityPanGesture {
    if (!_velocityPanGesture) {
        _velocityPanGesture = [[GKPopupPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePanGesture:)];
        _velocityPanGesture.delegate = self;
        _velocityPanGesture.direction = GKPopupPanGestureDirectionVelocity;
    }
    return _velocityPanGesture;
}

@end
