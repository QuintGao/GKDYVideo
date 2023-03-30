//
//  GKDYPlayerViewController.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYBaseViewController.h"
#import "GKDYVideoModel.h"
#import <JXCategoryView/JXCategoryView.h>

NS_ASSUME_NONNULL_BEGIN

@class GKDYPlayerViewController;

@protocol GKDYPlayerViewControllerDelegate <NSObject>

@optional;

- (void)playerVCDidClickShoot:(GKDYPlayerViewController *)playerVC;

//- (void)playerVC:(GKDYPlayerViewController *)playerVC controlView:(GKDYVideoControlView *)controlView isCritical:(BOOL)isCritical;

- (void)playerVC:(GKDYPlayerViewController *)playerVC didDragDistance:(CGFloat)distance isEnd:(BOOL)isEnd;

@end

@interface GKDYPlayerViewController : GKDYBaseViewController<JXCategoryListContentViewDelegate>

@property (nonatomic, weak) id<GKDYPlayerViewControllerDelegate> delegate;

@property (nonatomic, copy) NSString *tab;

@property (nonatomic, strong) GKDYVideoModel *model;

- (void)requestData:(void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
