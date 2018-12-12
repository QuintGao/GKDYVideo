//
//  UIImage+GKCategory.h
//  GKWYMusic
//
//  Created by gaokun on 2018/4/20.
//  Copyright © 2018年 gaokun. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (GKCategory)

/**
 根据颜色生成图片

 @param color 颜色
 @param size 图片大小
 @return 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

/**
 根据颜色生成（1，1）图片

 @param color 颜色
 @return 图片
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 改变图片颜色

 @param color 颜色
 @return 图片
 */
- (UIImage *)changeImageWithColor:(UIColor *)color;

@end
