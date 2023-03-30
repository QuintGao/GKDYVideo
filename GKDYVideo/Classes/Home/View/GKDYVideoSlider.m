//
//  GKDYVideoSlider.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/22.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoSlider.h"
#import <Masonry/Masonry.h>

@interface GKDYVideoSlider()<GKSliderViewPreviewDelegate>

@property (nonatomic, assign) CGFloat startLocationX;

@property (nonatomic, assign) float startValue;

@property (nonatomic, assign) BOOL isDragging;

@property (nonatomic, assign) BOOL isSeeking;

@property (nonatomic, assign) NSTimeInterval currentTime;

@property (nonatomic, assign) NSTimeInterval totalTime;

@end

@implementation GKDYVideoSlider

- (instancetype)init {
    if (self = [super init]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.sliderView];
    [self.sliderView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.right.bottom.equalTo(self);
        make.height.mas_offset(4);
    }];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:panGesture];
    
    [self showSmallSlider];
}

- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime {
    self.currentTime = currentTime;
    self.totalTime = totalTime;
    if (self.isDragging) return;
    if (self.isSeeking) return;
    CGFloat value = totalTime == 0 ? 0 : currentTime / totalTime;
    self.sliderView.value = value;
}

- (void)showLoading {
    [self.sliderView showLineLoading];
}

- (void)hideLoading {
    [self.sliderView hideLineLoading];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:gesture.view];
    switch (gesture.state) {
        case UIGestureRecognizerStateBegan: {
            self.startLocationX = location.x;
            self.startValue = self.sliderView.value;
            if (self.sliderView.preview) {
                self.sliderView.preview.hidden = NO;
            }
            self.isDragging = YES;
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showSmallSlider) object:nil];
            [self showLargeSlider];
            !self.slideBlock ?: self.slideBlock(self.isDragging);
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat diff = location.x - self.startLocationX;
            CGFloat progress = self.startValue + diff / gesture.view.frame.size.width;
            if (progress < 0) progress = 0;
            if (progress > 1) progress = 1;
            self.sliderView.value = progress;
            if (self.sliderView.preview && [self.sliderView.previewDelegate respondsToSelector:@selector(sliderView:preview:valueChanged:)]) {
                [self.sliderView.previewDelegate sliderView:self.sliderView preview:self.sliderView.preview valueChanged:self.sliderView.value];
            }
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showSmallSlider) object:nil];
            [self showDragSlider];
        }
            break;
        case UIGestureRecognizerStateFailed:
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            self.isDragging = NO;
            if (self.sliderView.preview) {
                self.sliderView.preview.hidden = YES;
            }
            [self showLargeSlider];
            [self performSelector:@selector(showSmallSlider) withObject:nil afterDelay:3.0f];
            !self.slideBlock ?: self.slideBlock(self.isDragging);
            [self seekTo:self.sliderView.value];
        }
            break;
            
        default:
            break;
    }
}

- (void)seekTo:(float)value {
    NSTimeInterval time = self.totalTime * value;
    
    self.isSeeking = YES;
    @weakify(self);
    [self.player seekToTime:time completionHandler:^(BOOL finished) {
        @strongify(self);
        self.isSeeking = NO;
    }];
}

#pragma mark - Slider
- (void)showSmallSlider {
    CGRect frame = self.sliderView.sliderBtn.frame;
    frame.size = CGSizeMake(4, 4);
    self.sliderView.sliderBtn.frame = frame;
    self.sliderView.sliderBtn.layer.cornerRadius = 2;
    self.sliderView.sliderHeight = 1;
    [self.sliderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(4);
    }];
    self.sliderView.bgCornerRadius = 0;
}

- (void)showLargeSlider {
    CGRect frame = self.sliderView.sliderBtn.frame;
    frame.size = CGSizeMake(8, 8);
    self.sliderView.sliderBtn.frame = frame;
    self.sliderView.sliderBtn.layer.cornerRadius = 4;
    self.sliderView.sliderHeight = 2;
    [self.sliderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(8);
    }];
    self.sliderView.bgCornerRadius = 1;
}

- (void)showDragSlider {
    CGRect frame = self.sliderView.sliderBtn.frame;
    frame.size = CGSizeMake(8, 16);
    self.sliderView.sliderBtn.frame = frame;
    self.sliderView.sliderBtn.layer.cornerRadius = 4;
    self.sliderView.sliderHeight = 10;
    [self.sliderView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(16);
    }];
    self.sliderView.bgCornerRadius = 5;
}

#pragma mark - GKSliderViewPreviewDelegate
- (UIView *)sliderViewSetupPreview:(GKSliderView *)sliderView {
    GKSliderButton *preview = [[GKSliderButton alloc] init];
    NSString *currentTime = [GKDYTools convertTimeSecond:self.currentTime];
    NSString *totalTime = [GKDYTools convertTimeSecond:self.totalTime];
    [preview setTitle:[NSString stringWithFormat:@"%@ / %@", currentTime, totalTime] forState:UIControlStateNormal];
    [preview setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    preview.titleLabel.font = [UIFont systemFontOfSize:15];
    [preview sizeToFit];
    CGRect frame = preview.frame;
    frame.size.width += 10;
    preview.frame = frame;
    return preview;
}

- (CGFloat)sliderViewPreviewMargin:(GKSliderView *)sliderView {
    return 60;
}

- (void)sliderView:(GKSliderView *)sliderView preview:(UIView *)preview valueChanged:(float)value {
    GKSliderButton *button = (GKSliderButton *)preview;
    NSString *currentTime = [GKDYTools convertTimeSecond:self.totalTime * value];
    NSString *totalTime = [GKDYTools convertTimeSecond:self.totalTime];
    [button setTitle:[NSString stringWithFormat:@"%@ / %@", currentTime, totalTime] forState:UIControlStateNormal];
}

#pragma mark - Lazy
- (GKSliderView *)sliderView {
    if (!_sliderView) {
        _sliderView = [[GKSliderView alloc] init];
        _sliderView.isSliderAllowTapped = NO;
        _sliderView.sliderHeight = 2;
        _sliderView.maximumTrackTintColor = [UIColor lightGrayColor];
        _sliderView.minimumTrackTintColor = [UIColor whiteColor];
        _sliderView.sliderBtn.layer.masksToBounds = YES;
        _sliderView.sliderBtn.backgroundColor = UIColor.whiteColor;
        _sliderView.isPreviewChangePosition = NO;
        _sliderView.userInteractionEnabled = NO;
        _sliderView.previewDelegate = self;
    }
    return _sliderView;
}

@end
