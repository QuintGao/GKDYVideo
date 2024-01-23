//
//  GKDYPanGestureRecognizer.h
//  GKDYVideo
//
//  Created by gaokun on 2019/7/31.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKDYPanGestureRecognizerDirection) {
    GKDYPanGestureRecognizerDirectionVertical,
    GKDYPanGestureRecognizerDirectionHorizontal
};

@interface GKDYPanGestureRecognizer : UIPanGestureRecognizer

@property (nonatomic, assign) GKDYPanGestureRecognizerDirection direction;

@end

NS_ASSUME_NONNULL_END
