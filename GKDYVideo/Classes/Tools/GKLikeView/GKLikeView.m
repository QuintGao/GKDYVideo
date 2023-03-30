//
//  GKLikeView.m
//  GKDYVideo
//
//  Created by gaokun on 2019/5/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKLikeView.h"

@interface GKLikeView()

@property (nonatomic, strong) UIImageView   *likeBeforeImgView;
@property (nonatomic, strong) UIImageView   *likeAfterImgView;

@property (nonatomic, strong) UILabel       *countLabel;

@end

@implementation GKLikeView

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.likeBeforeImgView];
        [self addSubview:self.likeAfterImgView];
        [self addSubview:self.countLabel];
        
        CGFloat imgWH = ADAPTATIONRATIO * 80.0f;
        self.likeBeforeImgView.frame = CGRectMake(0, 0, imgWH, imgWH);
        self.likeAfterImgView.frame  = CGRectMake(0, 0, imgWH, imgWH);
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tapGesture];
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGPoint imgCenter = self.likeBeforeImgView.center;
    imgCenter.x = self.frame.size.width / 2;
    self.likeBeforeImgView.center = imgCenter;
    self.likeAfterImgView.center  = imgCenter;
    
    [self.countLabel sizeToFit];
    
    CGFloat countX = (self.frame.size.width - self.countLabel.frame.size.width) / 2;
    CGFloat countY = self.frame.size.height - self.countLabel.frame.size.height;
    self.countLabel.frame = CGRectMake(countX, countY, self.countLabel.frame.size.width, self.countLabel.frame.size.height);
}

- (void)setupLikeState:(BOOL)isLike {
    self.isLike = isLike;
    
    if (isLike) {
        self.likeAfterImgView.hidden = NO;
    }else {
        self.likeAfterImgView.hidden = YES;
    }
}

- (void)setupLikeCount:(NSString *)count {
    self.countLabel.text = count;
    
    [self layoutSubviews];
}

- (void)startAnimationWithIsLike:(BOOL)isLike {
    if (self.isLike == isLike) return;
    
    self.isLike = isLike;
    
    if (isLike) {
        CGFloat length      = 30;
        CGFloat duration    = 0.5f;
        for (NSInteger i = 0; i < 6; i++) {
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.position = self.likeBeforeImgView.center;
            layer.fillColor = GKColorRGB(232, 50, 85).CGColor;

            UIBezierPath *startPath = [UIBezierPath bezierPath];
            [startPath moveToPoint:CGPointMake(-2, -length)];
            [startPath addLineToPoint:CGPointMake(2, -length)];
            [startPath addLineToPoint:CGPointMake(0, 0)];
            layer.path = startPath.CGPath;

            layer.transform = CATransform3DMakeRotation(M_PI / 3.0f * i, 0, 0, 1.0);
            [self.layer addSublayer:layer];

            CAAnimationGroup *group = [CAAnimationGroup animation];
            group.removedOnCompletion = NO;
            group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
            group.fillMode = kCAFillModeForwards;
            group.duration = duration;

            CABasicAnimation *scaleAnim = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
            scaleAnim.fromValue = @(0.0f);
            scaleAnim.toValue = @(1.0f);
            scaleAnim.duration = duration * 0.2f;

            UIBezierPath *endPath = [UIBezierPath bezierPath];
            [endPath moveToPoint:CGPointMake(-2, -length)];
            [endPath addLineToPoint:CGPointMake(2, -length)];
            [endPath addLineToPoint:CGPointMake(0, -length)];

            CABasicAnimation *pathAnim = [CABasicAnimation animationWithKeyPath:@"path"];
            pathAnim.fromValue = (__bridge id)layer.path;
            pathAnim.toValue = (__bridge id)endPath.CGPath;
            pathAnim.beginTime = duration * 0.2f;
            pathAnim.duration = duration * 0.8f;

            [group setAnimations:@[scaleAnim, pathAnim]];
            [layer addAnimation:group forKey:nil];
        }
        self.likeAfterImgView.hidden = NO;
        self.likeAfterImgView.alpha = 0.0f;
        
        self.likeAfterImgView.transform = CGAffineTransformMakeScale(0.1f, 0.1f);
        
        [UIView animateWithDuration:0.15 animations:^{
            self.likeAfterImgView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
            self.likeAfterImgView.alpha = 1.0f;
            self.likeBeforeImgView.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.likeAfterImgView.transform = CGAffineTransformIdentity;
            self.likeBeforeImgView.alpha = 1.0f;
        }];
    }else {
        self.likeAfterImgView.alpha = 1.0f;
        self.likeAfterImgView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        [UIView animateWithDuration:0.15 animations:^{
            self.likeAfterImgView.transform = CGAffineTransformMakeScale(0.3f, 0.3f);
        } completion:^(BOOL finished) {
            self.likeAfterImgView.transform = CGAffineTransformIdentity;
            self.likeAfterImgView.hidden = YES;
        }];
    }
}

#pragma mark - UITapGestureRecognizer
- (void)tapAction:(UITapGestureRecognizer *)tap {
    [self startAnimationWithIsLike:!self.isLike];
    !self.likeBlock ?: self.likeBlock();
}

#pragma mark - 懒加载
- (UIImageView *)likeBeforeImgView {
    if (!_likeBeforeImgView) {
        _likeBeforeImgView = [UIImageView new];
        _likeBeforeImgView.image = [UIImage imageNamed:@"ic_home_like_before"];
    }
    return _likeBeforeImgView;
}

- (UIImageView *)likeAfterImgView {
    if (!_likeAfterImgView) {
        _likeAfterImgView = [UIImageView new];
        _likeAfterImgView.image = [UIImage imageNamed:@"ic_home_like_after"];
    }
    return _likeAfterImgView;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [UILabel new];
        _countLabel.textColor = [UIColor whiteColor];
        _countLabel.font = [UIFont systemFontOfSize:13.0f];
    }
    return _countLabel;
}

@end
