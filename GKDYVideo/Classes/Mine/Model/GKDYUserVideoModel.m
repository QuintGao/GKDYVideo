//
//  GKDYUserVideoModel.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYUserVideoModel.h"

@implementation GKDYUserVideoModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"vid"  : @"content.vid",
             @"publish_time": @"content.publish_time",
             @"title": @"content.title",
             @"cover_src": @"content.cover_src",
             @"cover_src_pc": @"content.cover_src_pc",
             @"thumbnails": @"content.thumbnails",
             @"duration": @"content.duration",
             @"poster": @"content.poster",
             @"playcnt": @"content.playcnt",
             @"playcntText": @"content.playcntText"
    };
}

@end
