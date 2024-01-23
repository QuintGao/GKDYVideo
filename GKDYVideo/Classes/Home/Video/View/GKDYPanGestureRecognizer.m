//
//  GKDYPanGestureRecognizer.h
//  GKDYVideo
//
//  Created by gaokun on 2019/7/31.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKDYPanGestureRecognizer.h"

int const static kDirectionPanThreshold = 5;

@interface GKDYPanGestureRecognizer()

@property (nonatomic, assign) BOOL drag;
@property (nonatomic, assign) int moveX;
@property (nonatomic, assign) int moveY;

@end

@implementation GKDYPanGestureRecognizer

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    if (self.state == UIGestureRecognizerStateFailed) return;
    CGPoint nowPoint = [[touches anyObject] locationInView:self.view];
    CGPoint prevPoint = [[touches anyObject] previousLocationInView:self.view];
    _moveX += prevPoint.x - nowPoint.x;
    _moveY += prevPoint.y - nowPoint.y;
    if (!_drag) {
        if (abs(_moveX) > kDirectionPanThreshold) {
            if (_direction == GKDYPanGestureRecognizerDirectionVertical) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _drag = YES;
            }
        }else if (abs(_moveY) > kDirectionPanThreshold) {
            if (_direction == GKDYPanGestureRecognizerDirectionHorizontal) {
                self.state = UIGestureRecognizerStateFailed;
            }else {
                _drag = YES;
            }
        }
    }
}

- (void)reset {
    [super reset];
    _drag = NO;
    _moveX = 0;
    _moveY = 0;
}

@end
