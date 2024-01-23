//
//  GKDYShootViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2019/5/4.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKDYShootViewController.h"
#import "GKDYMainViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface GKDYShootViewController ()<GKViewControllerPushDelegate>

@property (nonatomic, strong) GKDYMainViewController    *mainVC;

// 负责输入和输出设备之间的数据传输
@property (nonatomic, strong) AVCaptureSession          *captureSession;
// 负责从AVCaptureDevice获取输入数据
@property (nonatomic, strong) AVCaptureDeviceInput      *captureDeviceInput;
// 照片输出流
//@property (nonatomic, strong) AVCaptureStillImageOutput *imageOutput;
// 视频输出流
@property (nonatomic, strong) AVCaptureMovieFileOutput  *videoOutput;

// 相机拍摄预览图层
@property (nonatomic, strong) AVCaptureVideoPreviewLayer    *capturePreviewLayer;

@property (nonatomic, strong) UIView                    *coverView;
@property (nonatomic, strong) UILabel                   *topLabel;
@property (nonatomic, strong) UILabel                   *descLabel;
@property (nonatomic, strong) UIButton                  *cameraAuthBtn; // 相机授权按钮
@property (nonatomic, strong) UIButton                  *microAuthBtn;  // 麦克风授权按钮

@end

@implementation GKDYShootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor clearColor];
    
//    self.gk_statusBarHidden = YES;
    self.gk_navBackgroundColor = [UIColor clearColor];
    
    self.gk_navLeftBarButtonItem = [UIBarButtonItem gk_itemWithImage:[UIImage gk_changeImage:[UIImage imageNamed:@"close"] color:UIColor.whiteColor] target:self action:@selector(closeAction)];
    
    [self.view addSubview:self.coverView];
    [self.view addSubview:self.topLabel];
    [self.view addSubview:self.descLabel];
    [self.view addSubview:self.cameraAuthBtn];
    [self.view addSubview:self.microAuthBtn];
    
    [self.coverView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.topLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view).offset(ADAPTATIONRATIO * 456.0f);
        make.centerX.equalTo(self.view);
    }];
    
    [self.descLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.topLabel.mas_bottom).offset(ADAPTATIONRATIO * 24.0f);
        make.centerX.equalTo(self.view);
    }];
    
    [self.cameraAuthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.descLabel.mas_bottom).offset(ADAPTATIONRATIO * 120.0f);
        make.centerX.equalTo(self.view);
    }];
    
    [self.microAuthBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.cameraAuthBtn.mas_bottom).offset(ADAPTATIONRATIO * 90.0f);
        make.centerX.equalTo(self.view);
    }];
    
    // 默认显示mainVC
    self.mainVC = [GKDYMainViewController new];
    [self.navigationController pushViewController:self.mainVC animated:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.gk_pushDelegate = self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.gk_pushDelegate = nil;
}

- (void)closeAction {
    [self pushToNextViewController];
}

#pragma mark - GKViewControllerPushDelegate
- (void)pushToNextViewController {
    [self.navigationController pushViewController:self.mainVC animated:YES];
}

#pragma mark - 懒加载
- (UIView *)coverView {
    if (!_coverView) {
        _coverView = [UIView new];
        _coverView.backgroundColor = [UIColor blackColor];
        _coverView.alpha = 0.5f;
    }
    return _coverView;
}

- (UILabel *)topLabel {
    if (!_topLabel) {
        _topLabel = [UILabel new];
        _topLabel.textColor = [UIColor whiteColor];
        _topLabel.text = @"发一个随拍";
        _topLabel.font = [UIFont systemFontOfSize:25];
    }
    return _topLabel;
}

- (UILabel *)descLabel {
    if (!_descLabel) {
        _descLabel = [UILabel new];
        _descLabel.textColor = GKColorGray(90);
        _descLabel.text = @"允许访问即可进入拍摄";
        _descLabel.font = [UIFont systemFontOfSize:15.0f];
    }
    return _descLabel;
}

- (UIButton *)cameraAuthBtn {
    if (!_cameraAuthBtn) {
        _cameraAuthBtn = [UIButton new];
        [_cameraAuthBtn setTitle:@"启用相机访问权限" forState:UIControlStateNormal];
        [_cameraAuthBtn setTitleColor:GKColorRGB(25, 126, 143) forState:UIControlStateNormal];
    }
    return _cameraAuthBtn;
}

- (UIButton *)microAuthBtn {
    if (!_microAuthBtn) {
        _microAuthBtn = [UIButton new];
        [_microAuthBtn setTitle:@"启用麦克风访问权限" forState:UIControlStateNormal];
        [_microAuthBtn setTitleColor:GKColorRGB(25, 126, 143) forState:UIControlStateNormal];
    }
    return _microAuthBtn;
}

@end
