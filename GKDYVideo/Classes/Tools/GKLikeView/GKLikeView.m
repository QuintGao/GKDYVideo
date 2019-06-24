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

@end

@implementation GKLikeView

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.likeBeforeImgView];
        [self addSubview:self.likeAfterImgView];
        
        self.likeBeforeImgView.frame = CGRectMake(0, 0, frame.size.width, frame.size.height);
        self.likeAfterImgView.frame  = CGRectMake(0, 0, frame.size.width, frame.size.height);
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)startAnimIsLike:(BOOL)isLike {
    self.likeBeforeImgView.userInteractionEnabled = NO;
    self.likeAfterImgView.userInteractionEnabled  = NO;
    
    if (self.isLike == isLike) {
        return;
    }
    
    self.isLike = isLike;
    
    if (isLike) {
        CGFloat length = 30;
        CGFloat duration = self.duration > 0 ? self.duration : 0.5f;
        for (NSInteger i = 0; i < 6; i++) {
            CAShapeLayer *layer = [CAShapeLayer layer];
            layer.position = self.likeBeforeImgView.center;
            layer.fillColor = self.fillColor ? self.fillColor.CGColor : [UIColor redColor].CGColor;

            UIBezierPath *startPath = [UIBezierPath bezierPath];
            [startPath moveToPoint:CGPointMake(-2, -length)];
            [startPath addLineToPoint:CGPointMake(2, -length)];
            [startPath addLineToPoint:CGPointMake(0, 0)];
            layer.path = startPath.CGPath;

            // 当x，y，z值为0时，代表在该轴方向上不进行旋转，当值为-1时，代表在该轴方向上进行逆时针旋转，当值为1时，代表在该轴方向上进行顺时针旋转
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
            self.likeBeforeImgView.userInteractionEnabled = YES;
            self.likeAfterImgView.userInteractionEnabled = YES;
        }];
    }else {
        self.likeAfterImgView.alpha = 1.0f;
        self.likeAfterImgView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
        [UIView animateWithDuration:0.15 animations:^{
            self.likeAfterImgView.transform = CGAffineTransformMakeScale(0.3f, 0.3f);
        } completion:^(BOOL finished) {
            self.likeAfterImgView.transform = CGAffineTransformIdentity;
            self.likeAfterImgView.hidden = YES;
            self.likeBeforeImgView.userInteractionEnabled = YES;
            self.likeAfterImgView.userInteractionEnabled = YES;
        }];
    }
}

#pragma mark - Gesture
- (void)handleTapGesture:(UITapGestureRecognizer *)tap {
    UIView *tapView = tap.view;
    
    if (tapView.tag == 0) { // 点赞
        [self startAnimIsLike:YES];
    }else if (tapView.tag == 1) { // 取消点赞
        [self startAnimIsLike:NO];
    }
}

- (void)tapAction:(UITapGestureRecognizer *)tap {
    NSLog(@"点赞。。。。");
}

#pragma mark - 懒加载
- (UIImageView *)likeBeforeImgView {
    if (!_likeBeforeImgView) {
        _likeBeforeImgView = [UIImageView new];
        _likeBeforeImgView.image = [UIImage imageNamed:@"ic_home_like_before"];
//        _likeBeforeImgView.userInteractionEnabled = YES;
        _likeBeforeImgView.tag = 0;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [_likeBeforeImgView addGestureRecognizer:tap];
    }
    return _likeBeforeImgView;
}

- (UIImageView *)likeAfterImgView {
    if (!_likeAfterImgView) {
        _likeAfterImgView = [UIImageView new];
        _likeAfterImgView.image = [UIImage imageNamed:@"ic_home_like_after"];
//        _likeAfterImgView.userInteractionEnabled = YES;
        _likeAfterImgView.tag = 1;
        _likeAfterImgView.hidden = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGesture:)];
        [_likeAfterImgView addGestureRecognizer:tap];
    }
    return _likeAfterImgView;
}

@end
