//
//  GKDYVideoPortraitCell.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/5/5.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoCell.h"
#import "GKDYPlayerManager.h"
#import "GKDYVideoPortraitView.h"

NS_ASSUME_NONNULL_BEGIN

@class GKDYVideoPortraitCell;

@protocol GKDYVideoPortraitCellDelegate <NSObject>

@optional;

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickIcon:(GKDYVideoModel *)model;

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickLike:(GKDYVideoModel *)model;

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickComment:(GKDYVideoModel *)model;

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickShare:(GKDYVideoModel *)model;

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickDanmu:(GKDYVideoModel *)model;

- (void)videoCell:(GKDYVideoPortraitCell *)cell didClickFullscreen:(GKDYVideoModel *)model;

- (void)videoCell:(GKDYVideoPortraitCell *)cell zoomBegan:(GKDYVideoModel *)model;

- (void)videoCell:(GKDYVideoPortraitCell *)cell zoomEnded:(GKDYVideoModel *)model isFullscreen:(BOOL)isFullscreen;

@end

@interface GKDYVideoPortraitCell : GKDYVideoCell

@property (nonatomic, weak) id<GKDYVideoPortraitCellDelegate> delegate;

@property (nonatomic, strong) GKDYVideoPortraitView *portraitView;

@property (nonatomic, weak) GKDYPlayerManager *manager;

- (void)closeFullscreen;

@end

NS_ASSUME_NONNULL_END
