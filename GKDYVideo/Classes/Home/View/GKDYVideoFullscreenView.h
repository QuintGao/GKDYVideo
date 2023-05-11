//
//  GKDYVideoFullscreenView.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/5/8.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZFPlayer/ZFPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoFullscreenView : UIView<ZFPlayerMediaControl>

@property (nonatomic, copy) void(^closeFullscreenBlock)(void);
@property (nonatomic, copy) void(^likeBlock)(void);

@end

NS_ASSUME_NONNULL_END
