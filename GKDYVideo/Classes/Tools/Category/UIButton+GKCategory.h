//
//  UIButton+GKCategory.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/22.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface UIButton (GKCategory)

/*
扩大UIButton响应区域

使用
   [enlargeButton setEnlargeEdge:20.0];
或者
   [enlargeButton setEnlargeEdgeWithTop:20 right:20 bottom:20 left:10];
*/

- (void)setEnlargeEdge:(CGFloat)size;
- (void)setEnlargeEdgeWithTop:(CGFloat)top left:(CGFloat)left bottom:(CGFloat)bottom right:(CGFloat)right;

@end

NS_ASSUME_NONNULL_END
