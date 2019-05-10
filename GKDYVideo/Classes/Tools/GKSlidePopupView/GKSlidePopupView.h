//
//  GKSlidePopupView.h
//  GKDYVideo
//
//  Created by QuintGao on 2019/4/27.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKSlidePopupView : UIView

+ (instancetype)popupViewWithFrame:(CGRect)frame contentView:(UIView *)contentView;

- (instancetype)initWithFrame:(CGRect)frame contentView:(UIView *)contentView;

- (void)showFrom:(UIView *)fromView completion:(void (^)(void))completion;

- (void)dismiss;

@end

NS_ASSUME_NONNULL_END
