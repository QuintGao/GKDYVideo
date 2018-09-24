//
//  GKDYVideoViewModel.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKDYVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoViewModel : NSObject

@property (nonatomic, assign) BOOL  has_more;

- (void)refreshNewListWithSuccess:(void(^)(NSArray *list))success
                            failure:(void(^)(NSError *error))failure;

- (void)refreshMoreListWithSuccess:(void(^)(NSArray *list))success
                            failure:(void(^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
