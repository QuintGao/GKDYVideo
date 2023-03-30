//
//  GKDYVideoCell.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDYVideoSlider.h"
#import "GKDYVideoModel.h"
#import "GKDYPlayerManager.h"

NS_ASSUME_NONNULL_BEGIN

@class GKDYVideoCell;

@protocol GKDYVideoCellDelegate <NSObject>

@optional;

- (void)videoCell:(GKDYVideoCell *)cell didClickIcon:(GKDYVideoModel *)model;

- (void)videoCell:(GKDYVideoCell *)cell didClickLike:(GKDYVideoModel *)model;

- (void)videoCell:(GKDYVideoCell *)cell didClickComment:(GKDYVideoModel *)model;

- (void)videoCell:(GKDYVideoCell *)cell didClickShare:(GKDYVideoModel *)model;

- (void)videoCell:(GKDYVideoCell *)cell didClickDanmu:(GKDYVideoModel *)model;

@end

@interface GKDYVideoCell : UIView

@property (nonatomic, weak) id<GKDYVideoCellDelegate> delegate;

@property (nonatomic, strong) GKDYVideoModel *model;

@property (nonatomic, strong) UIImageView *coverImgView;

@property (nonatomic, strong) GKDYVideoSlider *slider;

@property (nonatomic, strong) GKDYPlayerManager *manager;

- (void)showSmallSlider;
- (void)showLargeSlider;

- (void)resetView;

- (void)showLikeAnimation;

@end

NS_ASSUME_NONNULL_END
