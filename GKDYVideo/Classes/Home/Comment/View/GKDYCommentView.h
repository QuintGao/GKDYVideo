//
//  GKDYCommentView.h
//  GKDYVideo
//
//  Created by QuintGao on 2019/5/1.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDYVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@class GKDYCommentView;

@protocol GKDYCommentViewDelegate <NSObject>

- (void)commentViewDidClickClose:(GKDYCommentView *)commentView;

- (void)commentView:(GKDYCommentView *)commentView didClickUnfold:(BOOL)open;

@end

@interface GKDYCommentView : UIView

@property (nonatomic, weak) id<GKDYCommentViewDelegate> delegate;

- (void)requestDataWithModel:(GKDYVideoModel *)model;

@end

NS_ASSUME_NONNULL_END
