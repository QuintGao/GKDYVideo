//
//  GKRedPreloadManager.h
//  GKDYVideo
//
//  Created by QuintGao on 2024/4/29.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKRedPreloadManager : NSObject

+ (void)preloadVideoURL:(NSURL *)URL;

+ (void)preloadVideoJson:(NSString *)json;

+ (NSString *)cachePath;

@end

NS_ASSUME_NONNULL_END
