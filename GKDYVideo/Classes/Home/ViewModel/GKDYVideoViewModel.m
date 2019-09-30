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
    
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:@"video1" ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:videoPath];
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    NSArray *videoList = dic[@"data"][@"video_list"];
    
    NSMutableArray *array = [NSMutableArray new];
    for (NSDictionary *dict in videoList) {
        GKDYVideoModel *model = [GKDYVideoModel yy_modelWithDictionary:dict];
        [array addObject:model];
    }
    
    !success ? : success(array);
}

- (void)refreshMoreListWithSuccess:(void (^)(NSArray * _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    self.pn ++;
    
    if (self.pn >= 4) {
        NSArray *array = nil;
        !success ? : success(array);
        return;
    } 

    NSString *fileName = [NSString stringWithFormat:@"video%zd", self.pn];
    
    NSString *videoPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"json"];
    
    NSData *jsonData = [NSData dataWithContentsOfFile:videoPath];
    
    if (!jsonData) {
        NSArray *array = nil;
        !success ? : success(array);
        return;
    }
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableLeaves error:nil];
    
    NSArray *videoList = dic[@"data"][@"video_list"];
    
    NSMutableArray *array = [NSMutableArray new];
    for (NSDictionary *dict in videoList) {
        GKDYVideoModel *model = [GKDYVideoModel yy_modelWithDictionary:dict];
        [array addObject:model];
    }
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        !success ? : success(array);
    });
}

@end
