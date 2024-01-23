//
//  GKDYCommentModel.h
//  GKDYVideo
//
//  Created by QuintGao on 2024/1/18.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDYCommentInfoModel : NSObject

@property (nonatomic, copy) NSString *reply_id;

@property (nonatomic, copy) NSString *uname;

@property (nonatomic, copy) NSString *avatar;

@property (nonatomic, copy) NSString *content;

@property (nonatomic, copy) NSString *create_time;

@property (nonatomic, copy) NSString *create_time_text;

@end

@interface GKDYCommentModel : NSObject

@property (nonatomic, copy) NSString *request_id;

@property (nonatomic, copy) NSString *thread_id;

@property (nonatomic, copy) NSString *vid;

@property (nonatomic, copy) NSString *comment_count;

@property (nonatomic, strong) NSArray *list;

@property (nonatomic, assign) BOOL is_over;

@end

NS_ASSUME_NONNULL_END
