//
//  GKDYCommentView.h
//  GKDYVideo
//
//  Created by QuintGao on 2019/5/1.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDYVideoModel.h"
#import <ZFPlayer/ZFPlayer.h>
#import "GKDYVideoPortraitCell.h"

NS_ASSUME_NONNULL_BEGIN

@class GKDYCommentView;

@protocol GKDYCommentViewDelegate <NSObject>

- (void)commentView:(GKDYCommentView *)commentView showOrHide:(BOOL)show;

@end

@interface GKDYCommentView : UIView

@property (nonatomic, weak) id<GKDYCommentViewDelegate> delegate;

@property (nonatomic, weak) ZFPlayerController *player;

@property (nonatomic, weak) UIView *containerView;

@property (nonatomic, strong) GKDYVideoModel *videoModel;

- (void)refreshDataWithModel:(GKDYVideoModel *)model;

- (void)requestDataWithModel:(GKDYVideoModel *)model;

- (void)showWithCell:(GKDYVideoPortraitCell *)cell containerView:(UIView *)containerView;

@end

NS_ASSUME_NONNULL_END
