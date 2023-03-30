//
//  GKDYVideoMaskView.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/22.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoMaskView.h"

@interface GKDYVideoMaskView()

@property (nonatomic, assign) GKDYVideoMaskViewStyle style;

@end

@implementation GKDYVideoMaskView

+ (Class)layerClass {
    return CAGradientLayer.class;
}

- (instancetype)initWithStyle:(GKDYVideoMaskViewStyle)style {
    if (self = [super init]) {
        self.style = style;
        CAGradientLayer *maskGradientLayer = (id)self.layer;
        switch (self.style) {
            case GKDYVideoMaskViewStyle_Top: {
                maskGradientLayer.colors = @[(__bridge id)[UIColor colorWithWhite:0 alpha:0.8].CGColor,
                                             (__bridge id)[UIColor clearColor].CGColor];
            }
                break;
            case GKDYVideoMaskViewStyle_Bottom: {
                maskGradientLayer.colors = @[(__bridge id)[UIColor clearColor].CGColor,
                                             (__bridge id)[UIColor colorWithWhite:0 alpha:0.8].CGColor];
            }
                break;
        }
    }
    return self;
}

- (void)clearColors {
    CAGradientLayer *maskGradientLayer = (id)self.layer;
    maskGradientLayer.colors = nil;
}

@end
