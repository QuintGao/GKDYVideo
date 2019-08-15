//
//  GKDYVideoView.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDYVideoViewModel.h"
#import "GKDYVideoControlView.h"

NS_ASSUME_NONNULL_BEGIN

@class GKDYVideoView;

@protocol GKDYVideoViewDelegate <NSObject>

@optional

- (void)videoView:(GKDYVideoView *)videoView didClickIcon:(GKDYVideoModel *)videoModel;
- (void)videoView:(GKDYVideoView *)videoView didClickPraise:(GKDYVideoModel *)videoModel;
- (void)videoView:(GKDYVideoView *)videoView didClickComment:(GKDYVideoModel *)videoModel;
- (void)videoView:(GKDYVideoView *)videoView didClickShare:(GKDYVideoModel *)videoModel;
- (void)videoView:(GKDYVideoView *)videoView didScrollIsCritical:(BOOL)isCritical;
- (void)videoView:(GKDYVideoView *)videoView didPanWithDistance:(CGFloat)distance isEnd:(BOOL)isEnd;

@end

@interface GKDYVideoView : UIView

@property (nonatomic, weak) id<GKDYVideoViewDelegate>   delegate;

@property (nonatomic, strong) GKDYVideoViewModel        *viewModel;

@property (nonatomic, strong) UIButton                  *backBtn;

// 当前播放内容的视图
@property (nonatomic, strong) GKDYVideoControlView      *currentPlayView;

// 当前播放内容的索引
@property (nonatomic, assign) NSInteger                 currentPlayIndex;

- (instancetype)initWithVC:(UIViewController *)vc isPushed:(BOOL)isPushed;

- (void)setModels:(NSArray *)models index:(NSInteger)index;

- (void)pause;
- (void)resume;
- (void)destoryPlayer;

@end

NS_ASSUME_NONNULL_END
