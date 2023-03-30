//
//  PrefixHeader.pch
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#ifndef PrefixHeader_pch
#define PrefixHeader_pch

#import <GKNavigationBar/GKNavigationBar.h>
#import <AFNetworking/AFNetworking.h>
#import <Masonry/Masonry.h>
#import <YYModel/YYModel.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import <MJRefresh/MJRefresh.h>
#import "GKDYTools.h"

#pragma mark - UI
// 屏幕宽高
#define SCREEN_WIDTH        [UIScreen mainScreen].bounds.size.width
#define SCREEN_HEIGHT       [UIScreen mainScreen].bounds.size.height

// 适配比例
#define ADAPTATIONRATIO     SCREEN_WIDTH / 750.0f

// 导航栏高度与tabbar高度
#define NAVBAR_HEIGHT       (IS_iPhoneX ? 88.0f : 64.0f)
#define TABBAR_HEIGHT       (IS_iPhoneX ? 83.0f : 49.0f)

// 状态栏高度
#define STATUSBAR_HEIGHT    (IS_iPhoneX ? 44.0f : 20.0f)

// 安全区域（不包含状态栏）
#define SAFE_TOP            (IS_iPhoneX ? 24.0f : 0.0f)
#define SAFE_BTM            (IS_iPhoneX ? 34.0f : 0.0f)

// 判断是否是iPhone X系列
#define IS_iPhoneX          GK_NOTCHED_SCREEN

// 颜色
#define GKColorRGBA(r, g, b, a) [UIColor colorWithRed:(r / 255.0) green:(g / 255.0) blue:(b / 255.0) alpha:a]
#define GKColorRGB(r, g, b)     GKColorRGBA(r, g, b, 1.0)
#define GKColorGray(v)          GKColorRGB(v, v, v)

#define GKColorHEX(hexValue, a) GKColorRGBA(((float)((hexValue & 0xFF0000) >> 16)), ((float)((hexValue & 0xFF00) >> 8)), ((float)(hexValue & 0xFF)), a)

#define GKColorRandom           GKColorRGB(arc4random() % 255, arc4random() % 255, arc4random() % 255)

#define HEXCOLOR(hexValue,a) [UIColor colorWithRed:((float)((hexValue & 0xFF0000) >> 16))/255.0 green:((float)((hexValue & 0xFF00) >> 8))/255.0  blue:((float)(hexValue & 0xFF))/255.0 alpha:a]

// 来自YYKit
#ifndef weakify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define weakify(object) autoreleasepool{} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) autoreleasepool{} __block __typeof__(object) block##_##object = object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define weakify(object) try{} @finally{} {} __weak __typeof__(object) weak##_##object = object;
        #else
        #define weakify(object) try{} @finally{} {} __block __typeof__(object) block##_##object = object;
        #endif
    #endif
#endif

#ifndef strongify
    #if DEBUG
        #if __has_feature(objc_arc)
        #define strongify(object) autoreleasepool{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) autoreleasepool{} __typeof__(object) object = block##_##object;
        #endif
    #else
        #if __has_feature(objc_arc)
        #define strongify(object) try{} @finally{} __typeof__(object) object = weak##_##object;
        #else
        #define strongify(object) try{} @finally{} __typeof__(object) object = block##_##object;
        #endif
    #endif
#endif

#endif /* PrefixHeader_pch */
