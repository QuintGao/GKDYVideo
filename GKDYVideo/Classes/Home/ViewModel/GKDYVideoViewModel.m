//
//  GKDYVideoViewModel.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYVideoViewModel.h"
#import "GKNetworking.h"

@interface GKDYVideoViewModel()

// 页码
@property (nonatomic, assign) NSInteger pn;

@end

@implementation GKDYVideoViewModel

- (void)refreshNewListWithSuccess:(void (^)(NSArray * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    self.pn = 1;
    
    [self videoListRequestWithSuccess:success failure:failure];
}

- (void)refreshMoreListWithSuccess:(void (^)(NSArray * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    self.pn ++;
    
    [self videoListRequestWithSuccess:success failure:failure];
}

- (void)videoListRequestWithSuccess:(void (^)(NSArray * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"new_recommend_type"] = @"3";
    params[@"pn"] = @(self.pn);
    params[@"dl"] = @"2D41050C0F871E65D6717E7B2E4E944C";
    params[@"sign"] = @"3AD03F91B2064D75E1B2A8285720E2F1";
    params[@"_timestamp"] = @"1544061295026";
    params[@"timestamp"]  = @"1544061295026";
    params[@"net_type"]   = @"1";
    
    // 推荐列表
    NSString *url = @"http://c.tieba.baidu.com/c/f/nani/recommend/list";
    
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"video" ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:videoPath];
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    NSArray *videoList = [dic[@"data"][@"list"] firstObject][@"video_list"];
    
    NSMutableArray *array = [NSMutableArray new];
    for (NSDictionary *dict in videoList) {
        GKDYVideoModel *model = [GKDYVideoModel yy_modelWithDictionary:dict];
        [array addObject:model];
    }
    !success ? : success(array);
    
//    [GKNetworking get:url params:params success:^(id  _Nonnull responseObject) {
//        if ([responseObject[@"error_code"] integerValue] == 0) {
//            NSDictionary *data = responseObject[@"data"];
//
//            self.has_more = [data[@"has_more"] boolValue];
//
//            NSMutableArray *array = [NSMutableArray new];
//            for (NSDictionary *dic in data[@"video_list"]) {
//                GKDYVideoModel *model = [GKDYVideoModel yy_modelWithDictionary:dic];
//                [array addObject:model];
//            }
//
//            !success ? : success(array);
//        }else {
//            NSLog(@"%@", responseObject);
//        }
//    } failure:^(NSError * _Nonnull error) {
//        !failure ? : failure(error);
//    }];
}

@end
