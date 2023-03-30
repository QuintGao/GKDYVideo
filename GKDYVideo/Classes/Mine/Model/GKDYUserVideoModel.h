//
//  GKDYUserVideoModel.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDYUserVideoModel : NSObject

@property (nonatomic, copy) NSString *vid;

@property (nonatomic, copy) NSString *publish_time;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *cover_src;

@property (nonatomic, copy) NSString *cover_src_pc;

@property (nonatomic, copy) NSString *thumbnails;

@property (nonatomic, copy) NSString *duration;

@property (nonatomic, copy) NSString *poster;

@property (nonatomic, copy) NSString *playcnt;

@property (nonatomic, copy) NSString *playcntText;

@end

NS_ASSUME_NONNULL_END
