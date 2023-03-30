//
//  GKDYUserModel.h
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/28.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface GKDYUserModel : NSObject

@property (nonatomic, copy) NSString *author;
@property (nonatomic, copy) NSString *author_icon;
@property (nonatomic, copy) NSString *mthid;
@property (nonatomic, copy) NSString *authentication_content;
@property (nonatomic, copy) NSString *fansCnt;
@property (nonatomic, copy) NSString *fansCntText;
@property (nonatomic, copy) NSString *videoCount;
@property (nonatomic, copy) NSString *videoCntText;
@property (nonatomic, copy) NSString *totalPlaycnt;
@property (nonatomic, copy) NSString *totalPlaycntText;

@end

NS_ASSUME_NONNULL_END
