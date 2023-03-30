//
//  GKDYTitleView.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <JXCategoryView/JXCategoryView.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDYTitleView : UIView

@property (nonatomic, strong) JXCategoryTitleView *categoryView;

@property (nonatomic, copy) void(^loadingBlock)(void);

- (void)changeAlphaWithDistance:(CGFloat)distance isEnd:(BOOL)isEnd;

- (void)loadingEnd;

@end

NS_ASSUME_NONNULL_END
