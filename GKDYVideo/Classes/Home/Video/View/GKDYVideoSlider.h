//
//  GKDYVideoSlider.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/22.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GKSliderView/GKSliderView.h>
#import <ZFPlayer/ZFPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoSlider : UIView

@property (nonatomic, strong) GKSliderView *sliderView;

@property (nonatomic, copy) void(^slideBlock)(BOOL isDragging);

@property (nonatomic, weak) ZFPlayerController *player;

- (void)updateCurrentTime:(NSTimeInterval)currentTime totalTime:(NSTimeInterval)totalTime;

- (void)showSmallSlider;
- (void)showLargeSlider;

- (void)showLoading;
- (void)hideLoading;

@end

NS_ASSUME_NONNULL_END
