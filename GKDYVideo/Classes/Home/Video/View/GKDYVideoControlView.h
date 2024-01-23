//
//  GKDYVideoControlView.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//  播放器视图控制层

#import <UIKit/UIKit.h>
//#import "GKAWEModel.h"
#import <GKSliderView/GKSliderView.h>

NS_ASSUME_NONNULL_BEGIN

@class GKDYVideoControlView;

@protocol GKDYVideoControlViewDelegate <NSObject>

- (void)controlViewDidClickSelf:(GKDYVideoControlView *)controlView;

- (void)controlViewDidClickIcon:(GKDYVideoControlView *)controlView;

- (void)controlViewDidClickPriase:(GKDYVideoControlView *)controlView;

- (void)controlViewDidClickComment:(GKDYVideoControlView *)controlView;

- (void)controlViewDidClickShare:(GKDYVideoControlView *)controlView;

- (void)controlView:(GKDYVideoControlView *)controlView touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event;

@end

@interface GKDYVideoControlView : UIView

@property (nonatomic, weak) id<GKDYVideoControlViewDelegate> delegate;

// 视频封面图:显示封面并播放视频
@property (nonatomic, strong) UIImageView           *coverImgView;

@property (nonatomic, strong) id            model;

@property (nonatomic, strong) GKSliderView          *sliderView;

- (void)setProgress:(float)progress;

- (void)startLoading;
- (void)stopLoading;

- (void)showPlayBtn;
- (void)hidePlayBtn;

- (void)showLikeAnimation;
- (void)showUnLikeAnimation;

@end

NS_ASSUME_NONNULL_END
