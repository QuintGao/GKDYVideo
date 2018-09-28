//
//  GKDYPersonalModel.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/24.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYPersonalModel.h"

@implementation GKDYUserModel

@end

@implementation GKDYUserVideoList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [GKDYVideoModel class] };
}

@end

@implementation GKDYFavorVideoList

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : [GKDYVideoModel class] };
}

@end

@implementation GKDYPersonalModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"user"            : [GKDYUserModel class],
             @"user_video_list" : [GKDYUserVideoList class],
             @"favor_video_list": [GKDYFavorVideoList class] };
}

@end
