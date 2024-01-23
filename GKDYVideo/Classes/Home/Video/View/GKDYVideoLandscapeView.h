//
//  GKDYVideoLandscapeView.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZFPlayer/ZFPlayer.h>
#import "GKDYVideoModel.h"
#import "GKRotationManager.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoLandscapeView : UIView<ZFPlayerMediaControl>

@property (nonatomic, strong) GKDYVideoModel *model;

@property (nonatomic, weak) GKRotationManager *rotationManager;

@property (nonatomic, copy) void(^likeBlock)(GKDYVideoModel *model);

@property (nonatomic, copy) void(^singleTapBlock)(void);

- (void)startTimer;
- (void)destoryTimer;

@property (nonatomic, assign) BOOL isContainerShow;
- (void)showContainerView:(BOOL)animated;
- (void)hideContainerView:(BOOL)animated;

- (void)autoHide;

@end

NS_ASSUME_NONNULL_END
