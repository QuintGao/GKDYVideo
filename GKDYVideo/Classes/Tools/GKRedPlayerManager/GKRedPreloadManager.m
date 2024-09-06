//
//  GKRedPreloadManager.m
//  GKDYVideo
//
//  Created by QuintGao on 2024/4/29.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKRedPreloadManager.h"

@import RedPlayer;
@implementation GKRedPreloadManager

+ (NSString *)cachePath {
    NSString *dir = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
    NSString *cachePath = [dir stringByAppendingString:@"/preload"];
    return cachePath;
}

+ (void)initPreloadConfig {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [RedPreLoad initPreLoad:[self cachePath] maxSize:50*1024*1024]; // 50MB cache storage
        [RedPreLoad setPreLoadMsgCallback:^(const RedPreLoadTask task, RedPreLoadControllerMsgType msgType, void * _Nonnull userData) {
            NSString *url = task.url;
            if (msgType == RedPreLoadControllerMsgTypeError) {
                NSLog(@"RedPreload-[ERROR]：%@", [NSString stringWithFormat:@"url:%@，error：%d", url, task.error]);
            }else if (msgType == RedPreLoadControllerMsgTypeCompleted) {
                NSLog(@"RedPreload-[Completed]：%@", [NSString stringWithFormat:@"url:%@", url]);
            }else if (msgType == RedPreLoadControllerMsgTypeSpeed) {
                NSLog(@"RedPreload-[Speed]：%lld", task.tcpSpeed);
            }
        }];
    });
}

#pragma mark preload url
+ (void)preloadVideoURL:(NSURL *)URL {
    // Initialize preload during the first launch.
    [self initPreloadConfig];
    RedPreloadParam param = {
        [self cachePath],
        512 * 1024,
        @"",
        3000,
        0,
        @"",
        @""
    };
    
    NSLog(@"RedPreload -- %@", URL.absoluteString);
    
    RedPreLoad *task = [RedPreLoad new];
    [task open:URL param:param userData:NULL];
}

#pragma mark preload json
+ (void)preloadVideoJson:(NSString *)json {
    // Initialize preload during the first launch.
    [self initPreloadConfig];
    RedPreloadParam param = {
        [self cachePath],
        512 * 1024,
        @"",
        3000,
        0,
        @"",
        @""
    };
    
    RedPreLoad *task = [RedPreLoad new];
    [task openJson:json param:param userData:NULL];
}

@end
