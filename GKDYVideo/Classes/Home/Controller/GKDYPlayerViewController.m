//
//  GKDYPlayerViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYPlayerViewController.h"
#import "UIImage+GKCategory.h"

@interface GKDYPlayerViewController ()

@property (nonatomic, strong) UIButton  *searchBtn;

@property (nonatomic, strong) UIView    *titleView;
@property (nonatomic, strong) UIButton  *recBtn;
@property (nonatomic, strong) UIButton  *cityBtn;

@end

@implementation GKDYPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.gk_navigationBar.hidden = YES;
    self.gk_statusBarHidden = YES;
    
    [self.view addSubview:self.videoView];
    
    [self.view addSubview:self.searchBtn];
    
    [self.view addSubview:self.titleView];
    [self.titleView addSubview:self.recBtn];
    [self.titleView addSubview:self.cityBtn];
    
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15.0f);
        make.top.equalTo(self.view).offset(GK_SAVEAREA_TOP + 20.0f);
    }];
    
    [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.centerY.equalTo(self.searchBtn);
        make.width.mas_equalTo(160.0f);
        make.height.mas_equalTo(30.0f);
    }];
    
    [self.recBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleView);
        make.centerX.equalTo(self.titleView).offset(-24);
    }];
    
    [self.cityBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.titleView);
        make.centerX.equalTo(self.titleView).offset(24);
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}

- (void)dealloc {
    [self.videoView destoryPlayer];
}

- (void)searchClick:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:@"PlayerSearchClickNotification" object:nil];
}

- (void)itemClick:(id)sender {
    if (sender == self.recBtn) {
        self.recBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        self.cityBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        
        [self.recBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.cityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
    }else {
        self.recBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        self.cityBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        
        [self.recBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        [self.cityBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    }
}

#pragma mark - 懒加载
- (GKDYVideoView *)videoView {
    if (!_videoView) {
        _videoView = [[GKDYVideoView alloc] initWithVC:self isPushed:NO];
    }
    return _videoView;
}

- (UIButton *)searchBtn {
    if (!_searchBtn) {
        _searchBtn = [UIButton new];
        [_searchBtn setImage:[[UIImage imageNamed:@"nav_search"] changeImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_searchBtn addTarget:self action:@selector(searchClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _searchBtn;
}

- (UIView *)titleView {
    if (!_titleView) {
        _titleView = [UIView new];
    }
    return _titleView;
}

- (UIButton *)recBtn {
    if (!_recBtn) {
        _recBtn = [UIButton new];
        [_recBtn setTitle:@"推荐" forState:UIControlStateNormal];
        [_recBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        _recBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
        [_recBtn addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _recBtn;
}

- (UIButton *)cityBtn {
    if (!_cityBtn) {
        _cityBtn = [UIButton new];
        [_cityBtn setTitle:@"同城" forState:UIControlStateNormal];
        [_cityBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateNormal];
        _cityBtn.titleLabel.font = [UIFont systemFontOfSize:16.0f];
        [_cityBtn addTarget:self action:@selector(itemClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _cityBtn;
}

@end
