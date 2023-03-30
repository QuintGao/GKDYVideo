//
//  GKDYUserModel.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/28.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYUserModel.h"

@implementation GKDYUserModel

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"author"  : @"author.author",
             @"author_icon": @"author.author_icon",
             @"mthid": @"author.mthid",
             @"authentication_content": @"author.authentication_content",
             @"fansCnt": @"cnt.fansCnt",
             @"fansCntText": @"cnt.fansCntText",
             @"videoCount": @"cnt.videoCount",
             @"videoCntText": @"cnt.videoCntText",
             @"totalPlaycnt": @"cnt.totalPlaycnt",
             @"totalPlaycntText": @"cnt.totalPlaycntText"
    };
}

@end
