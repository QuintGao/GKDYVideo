//
//  GKDYCommentModel.m
//  GKDYVideo
//
//  Created by QuintGao on 2024/1/18.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKDYCommentModel.h"

@implementation GKDYCommentInfoModel

@end

@implementation GKDYCommentModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"list" : GKDYCommentInfoModel.class};
}

@end
