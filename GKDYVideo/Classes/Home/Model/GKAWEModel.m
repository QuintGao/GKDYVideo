//
//  GKAWEModel.m
//  GKDYVideo
//
//  Created by gaokun on 2021/4/14.
//  Copyright © 2021 QuintGao. All rights reserved.
//

#import "GKAWEModel.h"


@implementation GKAWEUri

@end

@implementation GKAWEStatistics

@end

@implementation GKAWEAuthor

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"avatar_larger" : [GKAWEUri class],
             @"avatar_thumb": [GKAWEUri class],
             @"avatar_medium": [GKAWEUri class]
    };
}

@end

@implementation GKAWEMusic

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"cover_large" : [GKAWEUri class],
             @"cover_thumb": [GKAWEUri class],
             @"cover_hd": [GKAWEUri class],
             @"cover_medium": [GKAWEUri class],
             @"play_url": [GKAWEUri class]
    };
}

@end

@implementation GKAWEVideo

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"origin_cover" : [GKAWEUri class],
             @"play_addr": [GKAWEUri class],
             @"cover": [GKAWEUri class],
             @"download_addr": [GKAWEUri class],
             @"play_addr_lowbr": [GKAWEUri class],
             @"dynamic_cover": [GKAWEUri class]
    };
}

@end

@implementation GKAWEModel

+ (NSDictionary *)modelContainerPropertyGenericClass {
    return @{@"label_top" : [GKAWEUri class],
             @"video": [GKAWEVideo class],
             @"author": [GKAWEAuthor class],
             @"music": [GKAWEMusic class],
             @"statistics": [GKAWEStatistics class]
    };
}

@end
