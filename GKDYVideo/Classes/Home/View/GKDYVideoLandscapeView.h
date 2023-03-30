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

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoLandscapeView : UIView<ZFPlayerMediaControl>

@property (nonatomic, strong) GKDYVideoModel *model;

@property (nonatomic, copy) void(^likeBlock)(GKDYVideoModel *model);

- (void)startTimer;
- (void)destoryTimer;

@end

NS_ASSUME_NONNULL_END
