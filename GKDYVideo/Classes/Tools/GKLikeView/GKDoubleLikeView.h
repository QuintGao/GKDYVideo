//
//  GKDoubleLikeView.h
//  GKDYVideo
//
//  Created by gaokun on 2019/6/19.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDoubleLikeView : NSObject

- (void)createAnimationWithPoint:(CGPoint)point view:(UIView *)view completion:(nullable void(^)(void))completion;

@end

NS_ASSUME_NONNULL_END
