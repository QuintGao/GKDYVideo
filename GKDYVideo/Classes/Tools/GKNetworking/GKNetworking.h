//
//  GKNetworking.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/24.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKNetworkingType) {
    GKNetworkingTypeGet,
    GKNetworkingTypePost
};

@interface GKNetworking : NSObject

+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObject))success failure:(void (^)(NSError *error))failure;

+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObject))success failure:(void (^)(NSError *error))failure;

@end

NS_ASSUME_NONNULL_END
