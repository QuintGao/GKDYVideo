//
//  GKDYPlayerViewController.m
//  GKDYVideo
//
//  Created by QuintGao on 2018/9/23.
//  Copyright © 2018 QuintGao. All rights reserved.
//

#import "GKDYPlayerViewController.h"
#import "UIImage+GKCategory.h"
#import "GKDYPersonalViewController.h"
#import "GKSlidePopupView.h"
#import "GKDYCommentView.h"

@interface GKDYPlayerViewController ()<GKDYVideoViewDelegate, GKViewControllerPushDelegate>

@property (nonatomic, strong) UIButton  *backBtn;
@property (nonatomic, strong) UIButton  *searchBtn;

@property (nonatomic, strong) UIView    *titleView;
@property (nonatomic, strong) UIButton  *recBtn;
@property (nonatomic, strong) UIButton  *cityBtn;

@property (nonatomic, strong) GKDYVideoModel    *model;
@property (nonatomic, strong) NSArray           *videos;
@property (nonatomic, assign) NSInteger         playIndex;

// 是否从某个控制器push过来
@property (nonatomic, assign) BOOL              isPushed;

@end

@implementation GKDYPlayerViewController

- (instancetype)initWithVideoModel:(GKDYVideoModel *)model {
    if (self = [super init]) {
        self.model = model;
        
        self.isPushed = YES;
    }
    return self;
}

- (instancetype)initWithVideos:(NSArray *)videos index:(NSInteger)index {
    if (self = [super init]) {
        self.videos = videos;
        self.playIndex = index;
        
        self.isPushed = YES;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.gk_navigationBar.hidden = YES;
    self.gk_statusBarHidden = YES;
    
    [self.view addSubview:self.videoView];
    
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    if (self.isPushed) {
        [self.view addSubview:self.backBtn];
        [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.view).offset(15.0f);
            make.top.equalTo(self.view).offset(GK_SAVEAREA_TOP + 20.0f);
            make.width.height.mas_equalTo(44.0f);
        }];
        
        if (!self.videos) {
            self.videos = @[self.videoView];
        }
        
        [self.videoView setModels:self.videos index:self.playIndex];
        
    }else {
        [self.view addSubview:self.searchBtn];
        
        [self.view addSubview:self.titleView];
        [self.titleView addSubview:self.recBtn];
        [self.titleView addSubview:self.cityBtn];
        
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
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    self.gk_pushDelegate = self;
    
    [self.videoView resume];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.gk_pushDelegate = nil;
    
    // 停止播放
    [self.videoView pause];
}

- (void)dealloc {
    [self.videoView destoryPlayer];
    
    NSLog(@"playerVC dealloc");
}

- (void)searchClick:(id)sender {
    
}

- (void)backClick:(id)sender {
    [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark - GKViewControllerPushDelegate
- (void)pushToNextViewController {
    GKDYPersonalViewController *personalVC = [GKDYPersonalViewController new];
    personalVC.model = self.videoView.currentPlayView.model;
    [self.navigationController pushViewController:personalVC animated:YES];
}

#pragma mark - GKDYVideoViewDelegate
- (void)videoView:(GKDYVideoView *)videoView didClickIcon:(GKDYVideoModel *)videoModel {
    GKDYPersonalViewController *personalVC = [GKDYPersonalViewController new];
    personalVC.model = videoModel;
    [self.navigationController pushViewController:personalVC animated:YES];
}

- (void)videoView:(GKDYVideoView *)videoView didClickPraise:(GKDYVideoModel *)videoModel {
    
}

- (void)videoView:(GKDYVideoView *)videoView didClickComment:(GKDYVideoModel *)videoModel {
    GKDYCommentView *commentView = [GKDYCommentView new];
    commentView.frame = CGRectMake(0, 0, GK_SCREEN_WIDTH, ADAPTATIONRATIO * 980.0f);
    
    
    GKSlidePopupView *popupView = [GKSlidePopupView popupViewWithFrame:[UIScreen mainScreen].bounds contentView:commentView];
    [popupView showFrom:[UIApplication sharedApplication].keyWindow];
}

- (void)videoView:(GKDYVideoView *)videoView didClickShare:(GKDYVideoModel *)videoModel {
    
}

#pragma mark - 懒加载
- (GKDYVideoView *)videoView {
    if (!_videoView) {
        _videoView = [[GKDYVideoView alloc] initWithVC:self isPushed:self.isPushed];
        _videoView.delegate = self;
    }
    return _videoView;
}

- (UIButton *)backBtn {
    if (!_backBtn) {
        _backBtn = [UIButton new];
        [_backBtn setImage:GKImage(@"btn_back_white") forState:UIControlStateNormal];
        [_backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _backBtn;
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
