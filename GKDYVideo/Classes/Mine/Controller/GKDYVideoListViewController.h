//
//  GKDYVideoListViewController.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYBaseViewController.h"
#import <GKPageSmoothView/GKPageSmoothView.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoListViewController : GKDYBaseViewController<GKPageSmoothListViewDelegate>

@property (nonatomic, strong) UICollectionView *collectionView;

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, assign) NSInteger selectedIndex;

@property (nonatomic, copy) void(^cellClickBlock)(NSArray *list, NSInteger index);

- (void)scrollItemToIndexPath:(NSIndexPath *)indexPath;

- (void)requestMoreCompletion:(void(^)(NSArray *list))completion;

@end

NS_ASSUME_NONNULL_END
