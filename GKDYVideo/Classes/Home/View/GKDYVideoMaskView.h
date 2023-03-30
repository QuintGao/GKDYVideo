//
//  GKDYVideoMaskView.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/22.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKDYVideoMaskViewStyle) {
    GKDYVideoMaskViewStyle_Top,     // 顶部，（上->下）从深到浅
    GKDYVideoMaskViewStyle_Bottom   // 底部，（上->下）从浅到深
};

@interface GKDYVideoMaskView : UIView

- (instancetype)initWithStyle:(GKDYVideoMaskViewStyle)style;

- (void)clearColors;

@end

NS_ASSUME_NONNULL_END
