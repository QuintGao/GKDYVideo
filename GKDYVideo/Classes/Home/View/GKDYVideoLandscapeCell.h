//
//  GKDYVideoLandscapeCell.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/5/5.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoCell.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoLandscapeCell : GKDYVideoCell

@property (nonatomic, assign) BOOL isShowTop;

@property (nonatomic, copy) void(^backClickBlock)(void);

- (void)hideTopView;
- (void)showTopView;

- (void)autoHide;

@end

NS_ASSUME_NONNULL_END
