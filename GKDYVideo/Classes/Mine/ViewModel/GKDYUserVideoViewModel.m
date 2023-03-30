//
//  GKDYUserVideoViewModel.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/27.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYUserVideoViewModel.h"
#import <AFNetworking/AFNetworking.h>
#import "GKDYUserVideoModel.h"

@implementation GKDYUserVideoViewModel

- (instancetype)init {
    if (self = [super init]) {
        self.ctime = @"";
    }
    return self;
}

- (void)requestData {
    @weakify(self);
    [self requestDataCompletion:^(BOOL success, NSArray * _Nullable list) {
        @strongify(self);
        !self.requestBlock ?: self.requestBlock(success);
    }];
}

- (void)requestDataCompletion:(void (^)(BOOL, NSArray * _Nullable))completion {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    
    NSString *url = [NSString stringWithFormat:@"https://haokan.baidu.com/web/author/listall?app_id=%@&ctime=%@&rn=10&searchAfter=&_api=1", self.uid, self.ctime];
    
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject[@"errno"] integerValue] == 0) {
            NSDictionary *data = responseObject[@"data"];
            
            if ([self.ctime isEqualToString:@""]) {
                [self.dataList removeAllObjects];
            }
 
            self.ctime = [NSString stringWithFormat:@"%@", data[@"ctime"]];
            self.hasMore = [data[@"has_more"] boolValue];
            NSArray *results = data[@"results"];
            NSMutableArray *list = [NSMutableArray array];
            [results enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                GKDYUserVideoModel *model = [GKDYUserVideoModel yy_modelWithDictionary:obj];
                [list addObject:model];
            }];
            [self.dataList addObjectsFromArray:list];
            !completion ?: completion(YES, list);
        }else {
            !completion ?: completion(NO, nil);
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        !completion ?: completion(NO, nil);
    }];
}

- (NSMutableArray *)dataList {
    if (!_dataList) {
        _dataList = [NSMutableArray array];
    }
    return _dataList;
}

@end
