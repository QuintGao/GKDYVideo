//
//  GKDYListCollectionViewCell.h
//  GKDYVideo
//
//  Created by gaokun on 2018/12/14.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDYVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYListCollectionViewCell : UICollectionViewCell

@property (nonatomic, strong) GKDYVideoModel    *model;

@property (nonatomic, strong) UIImageView   *coverImgView;

@end

NS_ASSUME_NONNULL_END
