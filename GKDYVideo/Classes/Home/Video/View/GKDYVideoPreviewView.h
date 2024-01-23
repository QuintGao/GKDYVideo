//
//  GKDYVideoPreviewView.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/22.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ZFPlayer/ZFPlayer.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoPreviewView : UIView

@property (nonatomic, weak) ZFPlayerController *player;

- (void)setPreviewValue:(float)value;

@end

NS_ASSUME_NONNULL_END
