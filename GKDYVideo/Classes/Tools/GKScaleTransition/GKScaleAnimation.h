//
//  GKScaleAnimation.h
//  GKDYVideo
//
//  Created by QuintGao on 2024/9/12.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKScaleType) {
    GKScaleType_Present,
    GKScaleType_Dismiss
};

@class GKScaleTransition;

@interface GKScaleAnimation : NSObject<UIViewControllerAnimatedTransitioning>

- (instancetype)initWithType:(GKScaleType)type transition:(GKScaleTransition *)transition;

@end

NS_ASSUME_NONNULL_END
