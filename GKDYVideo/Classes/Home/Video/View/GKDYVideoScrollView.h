//
//  GKDYVideoScrollView.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <GKVideoScrollView/GKVideoScrollView.h>

NS_ASSUME_NONNULL_BEGIN

@class GKDYVideoScrollView;

@protocol GKDYVideoScrollViewDelegate <NSObject, GKVideoScrollViewDelegate>

@optional

- (void)scrollView:(GKDYVideoScrollView *)scrollView didPanWithDistance:(CGFloat)distance isEnd:(BOOL)isEnd;

@end

@interface GKDYVideoScrollView : GKVideoScrollView

@property (nonatomic, weak) id<GKDYVideoScrollViewDelegate> delegate;

- (void)addPanGesture;

@end

NS_ASSUME_NONNULL_END
