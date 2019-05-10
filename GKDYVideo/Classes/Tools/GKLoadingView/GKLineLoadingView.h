//
//  GKLineLoadingView.h
//  GKDYVideo
//
//  Created by gaokun on 2019/5/7.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKLineLoadingView : UIView

+ (void)showLoadingInView:(UIView *)view withLineHeight:(CGFloat)lineHeight;

+ (void)hideLoadingInView:(UIView *)view;

@end

NS_ASSUME_NONNULL_END
