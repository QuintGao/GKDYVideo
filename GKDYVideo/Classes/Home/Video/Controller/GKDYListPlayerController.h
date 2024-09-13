//
//  GKDYListPlayerController.h
//  GKDYVideo
//
//  Created by QuintGao on 2024/9/9.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKDYBaseViewController.h"
#import "GKDYVideoScrollView.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYPlayerNavigationController : UINavigationController

@end

@protocol GKDYListPlayerControllerDelegate <NSObject>

- (UIView *)sourceViewWithIndex:(NSInteger)index;

@end

@interface GKDYListPlayerController : GKDYBaseViewController

@property (nonatomic, weak) id<GKDYListPlayerControllerDelegate> delegate;

@property (nonatomic, strong) GKDYVideoScrollView *scrollView;

@property (nonatomic, strong) NSMutableArray *videoList;
@property (nonatomic, assign) NSInteger index;

@end

NS_ASSUME_NONNULL_END
