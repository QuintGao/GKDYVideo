//
//  GKDYUserHeaderView.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDYUserModel.h"

NS_ASSUME_NONNULL_BEGIN

#define kDYUserHeaderHeight   (SCREEN_WIDTH * 260.0 / 345.0)
#define kDYUserHeaderBgHeight (SCREEN_WIDTH * 110.0 / 345.0)

@interface GKDYUserHeaderView : UIView

@property (nonatomic, strong) GKDYUserModel *model;

- (void)scrollViewDidScroll:(CGFloat)offsetY;

@end

NS_ASSUME_NONNULL_END
