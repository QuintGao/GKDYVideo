//
//  GKAWEModel.h
//  GKDYVideo
//
//  Created by gaokun on 2021/4/14.
//  Copyright © 2021 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKAWEUri : NSObject

@property (nonatomic, copy) NSString *uri;
@property (nonatomic, strong) NSArray *url_list;

@end

@interface GKAWEStatistics : NSObject

@property (nonatomic, copy) NSString *play_count;
@property (nonatomic, copy) NSString *aweme_id;
@property (nonatomic, copy) NSString *comment_count;
@property (nonatomic, copy) NSString *share_count;
@property (nonatomic, copy) NSString *digg_count;

@end

@interface GKAWEAuthor : NSObject

@property (nonatomic, copy) NSString *uid;
@property (nonatomic, copy) NSString *comment_setting;
@property (nonatomic, copy) NSString *youtube_channel_title;
@property (nonatomic, copy) NSString *following_count;
@property (nonatomic, copy) NSString *share_qrcode_uri;
@property (nonatomic, copy) NSString *youtube_channel_id;
@property (nonatomic, strong) GKAWEUri *avatar_larger;
@property (nonatomic, strong) GKAWEUri *avatar_thumb;
@property (nonatomic, strong) GKAWEUri *avatar_medium;
@property (nonatomic, copy) NSString *follower_count;
@property (nonatomic, copy) NSString *birthday;
@property (nonatomic, copy) NSString *nickname;
@property (nonatomic, copy) NSString *signature;

@end

@interface GKAWEMusic : NSObject

@property (nonatomic, copy) NSString *music_id;
@property (nonatomic, copy) NSString *status;
@property (nonatomic, copy) NSString *is_original;
@property (nonatomic, copy) NSString *offline_desc;
@property (nonatomic, copy) NSString *source_platform;
@property (nonatomic, strong) GKAWEUri *cover_large;
@property (nonatomic, strong) GKAWEUri *cover_thumb;
@property (nonatomic, strong) GKAWEUri *cover_hd;
@property (nonatomic, strong) GKAWEUri *cover_medium;
@property (nonatomic, strong) GKAWEUri *play_url;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *user_count;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *mid;
@property (nonatomic, copy) NSString *id_str;
@property (nonatomic, copy) NSString *is_restricted;
@property (nonatomic, copy) NSString *schema_url;

@end

@interface GKAWEVideo : NSObject

@property (nonatomic, copy) NSString *video_id;
@property (nonatomic, copy) NSString *ratio;
@property (nonatomic, strong) GKAWEUri *origin_cover;
@property (nonatomic, strong) GKAWEUri *play_addr;
@property (nonatomic, strong) GKAWEUri *cover;
@property (nonatomic, strong) GKAWEUri *download_addr;
@property (nonatomic, strong) GKAWEUri *play_addr_lowbr;
@property (nonatomic, strong) GKAWEUri *dynamic_cover;
@property (nonatomic, copy) NSString *width;
@property (nonatomic, copy) NSString *height;
@property (nonatomic, copy) NSString *duration;
@property (nonatomic, copy) NSString *has_watermark;

@end

@interface GKAWEModel : NSObject

@property (nonatomic, copy) NSString *aweme_id;
@property (nonatomic, strong) GKAWEUri *label_top;
@property (nonatomic, copy) NSString *author_user_id;
@property (nonatomic, copy) NSString *create_time;
@property (nonatomic, strong) GKAWEVideo *video;
@property (nonatomic, strong) GKAWEAuthor *author;
@property (nonatomic, strong) GKAWEMusic *music;
@property (nonatomic, copy) NSString *desc;
@property (nonatomic, copy) NSString *region;
@property (nonatomic, strong) GKAWEStatistics *statistics;

@property (nonatomic, assign) BOOL is_like;

@end

NS_ASSUME_NONNULL_END
