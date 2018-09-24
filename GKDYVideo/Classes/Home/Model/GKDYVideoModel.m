//
//  GKDYVideoModel.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYVideoModel.h"

@implementation GKDYVideoAuthorModel

@end

@implementation GKDYVideoModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"author" : [GKDYVideoAuthorModel class]};
}

@end
