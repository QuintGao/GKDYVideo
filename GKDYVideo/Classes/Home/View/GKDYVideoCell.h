//
//  GKDYVideoCell.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/17.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GKVideoScrollView/GKVideoScrollView.h>
#import "GKDYVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoCell : GKVideoViewCell

@property (nonatomic, strong) GKDYVideoModel *model;

@property (nonatomic, strong) UIImageView *coverImgView;

- (void)initUI;

- (void)loadData:(GKDYVideoModel *)model;

- (void)resetView;

@end

NS_ASSUME_NONNULL_END
