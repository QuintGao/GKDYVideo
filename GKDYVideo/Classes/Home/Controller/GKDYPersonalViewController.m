//
//  GKDYPersonalViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/24.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYPersonalViewController.h"
#import "GKNetworking.h"
#import "GKDYPersonalModel.h"

@interface GKDYPersonalViewController ()

@end

@implementation GKDYPersonalViewController

- (void)loadView {
    self.view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"WechatIMG238"]];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.gk_navigationBar.hidden = YES;
}

//- (void)viewDidLoad {
//    [super viewDidLoad];

    
////    _client_type    1
////    _client_version    2.2.0
////    _os_version    12.0
////    _phone_imei    9A910F65D70DBAE95866E00B75934C78|com.baidu.nani
////    _phone_newimei    9A910F65D70DBAE95866E00B75934C78|com.baidu.nani
////    _timestamp    1537780403238
////    brand    iPad
////    brand_type    Unknown iPad
////    cuid    9A910F65D70DBAE95866E00B75934C78|com.baidu.nani
////    diuc    C2D95DB95D613410309F81193FB324F01F9B14E32FHFSIKTGGF
////    dl    8631E6A1267D19317CCD5435CC96C124
////    from    AppStore
////    model    Unknown iPad
////    nani_idfa    86294854-68D7-49CD-A8FD-6804980FE590
////    net_type    1
////    sign    555DA67D4E9EF016453326FF438638D4
////    subapp_type    nani
////    timestamp    1537780403238
////    z_id    rFrPVimBUvWH5P7FBld1NBSx7OoCUk8yiHZ8-LLBkC1Wfri7C904CDCrYh9EgDRp64f3LSQZAfGS3XO0hD5ri4w
//
//
//    //    is_from    11
//    //    obj_source    2
//    //    uid    1539787163
//    //    tbs    73254f0d29744cbf1537693822
//
//    NSMutableDictionary *params = [NSMutableDictionary new];
////    params[@"is_from"] = @11;
////    params[@"obj_source"] = @2;
//    params[@"uid"] = @"3611602824";
//
//    params[@"dl"] = @"7540247DBDF8FA61E4C40BC709F6F358";
//    params[@"sign"] = @"53F4AF8BDD25644EB62A74CBB25A8D47";
//    params[@"_timestamp"] = @"1537783026900";
//    params[@"timestamp"] = @"1537783026900";
//    params[@"net_type"] = @1;
//    params[@"obj_source"] = @2;
//    params[@"is_from"] = @11;
//
//    NSString *url = @"http://c.tieba.baidu.com/c/u/nani/profile";
//
//    [GKNetworking get:url params:params success:^(id  _Nonnull responseObject) {
//        NSLog(@"%@", responseObject);
//
//        GKDYProfileModel *model = [GKDYProfileModel yy_modelWithDictionary:responseObject[@"data"]];
//
//        NSLog(@"%@", model);
//    } failure:^(NSError * _Nonnull error) {
//
//    }];
//}

@end
