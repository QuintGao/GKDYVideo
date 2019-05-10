//
//  GKSliderView.h
//  GKSliderView
//
//  Created by QuintGao on 2017/9/6.
//  Copyright © 2017年 高坤. All rights reserved.
//  自定义的一个slider

#import <UIKit/UIKit.h>

@protocol GKSliderViewDelegate <NSObject>

@optional
// 滑块滑动开始
- (void)sliderTouchBegan:(float)value;
// 滑块滑动中
- (void)sliderValueChanged:(float)value;
// 滑块滑动结束
- (void)sliderTouchEnded:(float)value;
// 滑杆点击
- (void)sliderTapped:(float)value;

@end

@interface GKSliderView : UIView

@property (nonatomic, weak) id<GKSliderViewDelegate> delegate;

/** 默认滑杆的颜色 */
@property (nonatomic, strong) UIColor *maximumTrackTintColor;
/** 滑杆进度颜色 */
@property (nonatomic, strong) UIColor *minimumTrackTintColor;
/** 缓存进度颜色 */
@property (nonatomic, strong) UIColor *bufferTrackTintColor;

/** 默认滑杆的图片 */
@property (nonatomic, strong) UIImage *maximumTrackImage;
/** 滑杆进度的图片 */
@property (nonatomic, strong) UIImage *minimumTrackImage;
/** 缓存进度的图片 */
@property (nonatomic, strong) UIImage *bufferTrackImage;

/** 滑杆进度 */
@property (nonatomic, assign) float value;
/** 缓存进度 */
@property (nonatomic, assign) float bufferValue;

/** 是否允许点击，默认是YES */
@property (nonatomic, assign) BOOL allowTapped;
/** 设置滑杆的高度 */
@property (nonatomic, assign) CGFloat sliderHeight;

/** 是否隐藏滑块（默认为NO） */
@property (nonatomic, assign) BOOL isHideSliderBlock;

// 设置滑块背景色
- (void)setBackgroundImage:(UIImage *)image forState:(UIControlState)state;
// 设置滑块图片
- (void)setThumbImage:(UIImage *)image forState:(UIControlState)state;

// 显示菊花动画
- (void)showLoading;
// 隐藏菊花动画
- (void)hideLoading;

- (void)showLineLoading;
- (void)hideLineLoading;

@end

@interface GKSliderButton : UIButton

- (void)showActivityAnim;
- (void)hideActivityAnim;

@end

@interface UIView (GKFrame)

@property (nonatomic, assign) CGFloat gk_top;
@property (nonatomic, assign) CGFloat gk_left;
@property (nonatomic, assign) CGFloat gk_right;
@property (nonatomic, assign) CGFloat gk_bottom;
@property (nonatomic, assign) CGFloat gk_width;
@property (nonatomic, assign) CGFloat gk_height;
@property (nonatomic, assign) CGFloat gk_centerX;
@property (nonatomic, assign) CGFloat gk_centerY;

@end
