//
//  GKDYMainViewController.h
//  GKDYVideo
//
//  Created by gaokun on 2018/12/12.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDYPlayerViewController.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYMainViewController : UITabBarController

@property (nonatomic, strong) GKDYPlayerViewController  *playerVC;

@end

NS_ASSUME_NONNULL_END
