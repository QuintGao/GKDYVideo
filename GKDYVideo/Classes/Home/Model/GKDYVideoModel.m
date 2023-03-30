//
//  GKDYVideoModel.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYVideoModel.h"

@implementation GKDYVideoModel

- (instancetype)initWithModel:(GKDYUserVideoModel *)model {
    if (self = [super init]) {
        self.video_id = model.vid;
        self.title = model.title;
        self.poster_small = model.poster;
        self.poster_big = model.cover_src;
        self.poster_pc = model.cover_src_pc;
        self.duration = model.duration;
        self.publish_time = model.publish_time;
        self.playcnt = model.playcnt;
        self.fmplaycnt = model.playcntText;
    }
    return self;
}

+ (NSDictionary *)modelCustomPropertyMapper {
    return @{@"video_id"  : @"id"};
}

@end
