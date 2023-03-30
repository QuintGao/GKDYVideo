//
//  GKDYVideoListCell.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDYUserVideoModel.h"
#import <SDWebImage/SDAnimatedImageView.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoListCell : UICollectionViewCell

@property (nonatomic, strong) GKDYUserVideoModel *model;

@property (nonatomic, strong) SDAnimatedImageView *coverImgView;

@end

NS_ASSUME_NONNULL_END
