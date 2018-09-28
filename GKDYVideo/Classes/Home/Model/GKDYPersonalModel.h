//
//  GKDYPersonalModel.h
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/24.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GKDYVideoModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYUserModel : NSObject

@property (nonatomic, copy) NSString    *intro;
@property (nonatomic, copy) NSString    *age;
@property (nonatomic, copy) NSString    *nani_id;
@property (nonatomic, copy) NSString    *club_num;
@property (nonatomic, copy) NSString    *is_follow;
@property (nonatomic, copy) NSString    *fans_num;
@property (nonatomic, copy) NSString    *user_id;
@property (nonatomic, copy) NSString    *video_num;
@property (nonatomic, copy) NSString    *user_name;
@property (nonatomic, copy) NSString    *portrait;
@property (nonatomic, copy) NSString    *name_show;
@property (nonatomic, copy) NSString    *agree_num;
@property (nonatomic, copy) NSString    *favor_num;
@property (nonatomic, copy) NSString    *gender;
@property (nonatomic, copy) NSString    *follow_num;

@end

@interface GKDYUserVideoList : NSObject

@property (nonatomic, copy) NSString        *has_more;
@property (nonatomic, strong) NSArray       *list;

@end

@interface GKDYFavorVideoList : NSObject

@property (nonatomic, copy) NSString        *has_more;
@property (nonatomic, strong) NSArray       *list;

@end

@interface GKDYPersonalModel : NSObject

@property (nonatomic, strong) GKDYUserModel         *user;
@property (nonatomic, strong) GKDYUserVideoList     *user_video_list;
@property (nonatomic, strong) GKDYFavorVideoList    *favor_video_list;

@end

NS_ASSUME_NONNULL_END
