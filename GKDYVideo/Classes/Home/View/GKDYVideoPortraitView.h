//
//  GKDYVideoPortraitView.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZFPlayer/ZFPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoPortraitView : UIView<ZFPlayerMediaControl>

@property (nonatomic, strong) UIButton *playBtn;

@property (nonatomic, copy) void(^likeBlock)(void);

@end

NS_ASSUME_NONNULL_END
