//
//  GKDYUserVideoViewModel.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDYUserVideoViewModel : NSObject

@property (nonatomic, copy) NSString *uid;

@property (nonatomic, copy) NSString *ctime;

@property (nonatomic, assign) BOOL hasMore;

@property (nonatomic, strong) NSMutableArray *dataList;

@property (nonatomic, copy) void(^requestBlock)(BOOL success);

- (void)requestData;
- (void)requestDataCompletion:(void(^)(BOOL success, NSArray *_Nullable list))completion;

@end

NS_ASSUME_NONNULL_END
