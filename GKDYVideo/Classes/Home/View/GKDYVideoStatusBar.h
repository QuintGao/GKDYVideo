//
//  GKDYVideoStatusBar.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/22.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoStatusBar : UIView

// 刷新时间，默认3s
@property (nonatomic, assign) NSTimeInterval refreshTime;

// 网络状态
@property (nonatomic, copy) NSString *network;

- (void)startTimer;

- (void)destoryTimer;

@end

NS_ASSUME_NONNULL_END
