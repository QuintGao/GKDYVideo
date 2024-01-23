//
//  GKDYVideoModel.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKDYUserVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYVideoModel : NSObject

@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *poster_small;
@property (nonatomic, copy) NSString *poster_big;
@property (nonatomic, copy) NSString *poster_pc;
@property (nonatomic, copy) NSString *source_name;
@property (nonatomic, copy) NSString *play_url;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *url;
@property (nonatomic, copy) NSString *show_tag;
@property (nonatomic, copy) NSString *publish_time;
@property (nonatomic, copy) NSString *is_pay_column;
@property (nonatomic, copy) NSString *like;
@property (nonatomic, copy) NSString *comment;
@property (nonatomic, copy) NSString *playcnt;
@property (nonatomic, copy) NSString *fmplaycnt;
@property (nonatomic, copy) NSString *fmplaycnt_2;
@property (nonatomic, copy) NSString *outstand_tag;
@property (nonatomic, copy) NSString *previewUrlHttp;
@property (nonatomic, copy) NSString *third_id;
@property (nonatomic, copy) NSString *vip;
@property (nonatomic, copy) NSString *author_avatar;

@property (nonatomic, assign) BOOL isLike;
@property (nonatomic, strong, nullable) NSURLSessionDataTask *task;

@property (nonatomic, assign) BOOL isRequest;
@property (nonatomic, assign) BOOL requested;

- (instancetype)initWithModel:(GKDYUserVideoModel *)model;

@end

NS_ASSUME_NONNULL_END
