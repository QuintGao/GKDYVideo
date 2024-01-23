//
//  GKDYVideoPortraitView.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZFPlayer/ZFPlayer.h>
#import "GKDYVideoModel.h"
#import "GKDYVideoSlider.h"
#import "GKLikeView.h"

NS_ASSUME_NONNULL_BEGIN

@protocol GKDYVideoPortraitViewDelegate <NSObject>

- (void)didClickIcon:(GKDYVideoModel *)model;
- (void)didClickLike:(GKDYVideoModel *)model;
- (void)didClickComment:(GKDYVideoModel *)model;
- (void)didClickShare:(GKDYVideoModel *)model;
- (void)didClickDanmu:(GKDYVideoModel *)model;
- (void)didClickFullscreen:(GKDYVideoModel *)model;

@end

@interface GKDYVideoPortraitView : UIView<ZFPlayerMediaControl>

@property (nonatomic, weak) id<GKDYVideoPortraitViewDelegate> delegate;

@property (nonatomic, strong) GKDYVideoModel *model;

@property (nonatomic, strong) UIView *bottomView;

@property (nonatomic, strong) GKDYVideoSlider *slider;

@property (nonatomic, strong) GKLikeView *likeView;

@property (nonatomic, strong) UIButton *playBtn;

- (void)willBeginDragging;
- (void)didEndDragging;

@end

NS_ASSUME_NONNULL_END
