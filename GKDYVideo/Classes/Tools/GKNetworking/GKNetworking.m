//
//  GKNetworking.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/24.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKNetworking.h"

@implementation GKNetworking

+ (void)get:(NSString *)url params:(NSDictionary *)params success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    [self requestWithType:GKNetworkingTypeGet url:url params:params success:success failure:failure];
}

+ (void)post:(NSString *)url params:(NSDictionary *)params success:(void (^)(id _Nonnull))success failure:(void (^)(NSError * _Nonnull))failure {
    [self requestWithType:GKNetworkingTypePost url:url params:params success:success failure:failure];
}

+ (void)requestWithType:(GKNetworkingType)type url:(NSString *)url params:(NSDictionary *)params success:(void(^)(id responseObject))success failure:(void (^)(NSError *error))failure {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    [manager.requestSerializer setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    [manager.responseSerializer setAcceptableContentTypes:[NSSet setWithObjects:@"application/json", @"text/html", @"text/json", @"text/javascript", @"application/x-javascript", nil]];
    
    NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:params];
    dic[@"_client_type"] = @"1";
    dic[@"_client_version"] = @"2.2.4";
    dic[@"_os_version"] = @"12.1";
    dic[@"_phone_imei"] = @"3230B368FC82012CA6C6E6B5CFC829EA|com.baidu.nani";
    dic[@"_phone_newimei"] = @"3230B368FC82012CA6C6E6B5CFC829EA|com.baidu.nani";
    
    dic[@"brand"] = @"iPhone";
    dic[@"brand_type"] = @"iPhone 7 Plus";
    dic[@"cuid"] = @"3230B368FC82012CA6C6E6B5CFC829EA|com.baidu.nani";
    dic[@"diuc"] = @"1EA854F6332A764F436C48C069D5102C01A475EB7FHRPHGSJHA";
    dic[@"from"] = @"AppStore";
    dic[@"model"] = @"iPhone 7 Plus";
    dic[@"nani_idfa"] = @"D3993E61-276E-40E2-850A-50308E018015";
    dic[@"subapp_type"] = @"nani";
//
//    dic[@"z_id"] = @"FWUSehM4YgkAAAACVAEAAG8Ba0plAAAQAAAAAAAAAAA8OfwlgbRLLLw6XQUnvgx0Zj0GMglnRRgjOWAYewAyClV3VyNCSQZjA0AUT1MsfCA";
//    dic[@"dl"] = @"B650D852850FD5D326774B621C25ECCE";
//    dic[@"sign"] = @"602DB4C8DF0203B34DBB69B3A1E1F0AC";
    
    dic[@"z_id"] = @"QalvgJaNt6mIjT6pGBD1sdxZ2aBNkPoxA9RSgEaHiHWGKC-tA7u-cCgGMAp7iQPZSknfXHa6Whwf6LQGX438_fw";
//    dic[@"tbs"] = @"73254f0d29744cbf1537693822";
    
    if (type == GKNetworkingTypeGet) {
        [manager GET:url parameters:dic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            !success ? : success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            !failure ? : failure(error);
        }];
    }else {
        [manager POST:url parameters:dic headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            !success ? : success(responseObject);
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            !failure ? : success(error);
        }];
    }
}

@end
