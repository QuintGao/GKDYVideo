//
//  GKDYHeaderView.h
//  GKPageScrollView
//
//  Created by QuintGao on 2018/10/28.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDYVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

#define kDYHeaderHeight (SCREEN_WIDTH * 260.0f / 345.0f)
#define kDYBgImgHeight  (SCREEN_WIDTH * 110.0f / 345.0f)

@interface GKDYHeaderView : UIView

@property (nonatomic, strong) GKDYVideoModel    *model;

- (void)scrollViewDidScroll:(CGFloat)offsetY;

@end

NS_ASSUME_NONNULL_END
