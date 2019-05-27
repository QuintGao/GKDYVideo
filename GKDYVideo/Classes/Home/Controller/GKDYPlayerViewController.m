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
#import "GKBallLoadingView.h"

#define kTitleViewY         (GK_SAVEAREA_TOP + 20.0f)
// 过渡中心点
#define kTransitionCenter   20.0f

@interface GKDYPlayerViewController ()<GKDYVideoViewDelegate, GKViewControllerPushDelegate>

@property (nonatomic, strong) UIView                *titleView;
@property (nonatomic, strong) UIButton              *shootBtn;  // 随拍

@property (nonatomic, strong) UIView                *refreshView;
@property (nonatomic, strong) UILabel               *refreshLabel;
@property (nonatomic, strong) UIView                *loadingBgView;
@property (nonatomic, strong) GKBallLoadingView     *refreshLoadingView;

@property (nonatomic, strong) UIButton              *backBtn;
@property (nonatomic, strong) UIButton              *searchBtn;

@property (nonatomic, strong) UIButton              *recBtn;
@property (nonatomic, strong) UIButton              *cityBtn;

@property (nonatomic, strong) GKDYVideoModel        *model;
@property (nonatomic, strong) NSArray               *videos;
@property (nonatomic, assign) NSInteger             playIndex;

// 是否从某个控制器push过来
@property (nonatomic, assign) BOOL                  isPushed;
@property (nonatomic, assign) BOOL                  isRefreshing;

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
        [self.titleView addSubview:self.shootBtn];
        [self.titleView addSubview:self.recBtn];
        [self.titleView addSubview:self.cityBtn];
        [self.titleView addSubview:self.searchBtn];
        
        [self.view addSubview:self.refreshView];
        [self.refreshView addSubview:self.refreshLabel];
        [self.view addSubview:self.loadingBgView];
        
        self.loadingBgView.frame = CGRectMake(SCREEN_WIDTH - 15 - 44, GK_SAVEAREA_TOP, 44, 44);
        self.refreshLoadingView = [GKBallLoadingView loadingViewInView:self.loadingBgView];
        
        [self.titleView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).offset(GK_SAVEAREA_TOP + 20.0f);
            make.height.mas_equalTo(44.0f);
        }];
        
        [self.shootBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleView);
            make.left.equalTo(self.view).offset(15.0f);
            make.width.mas_offset(ADAPTATIONRATIO * 150.0f);
            make.height.mas_equalTo(44.0f);
        }];
        
        [self.searchBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.view).offset(-15.0f);
            make.centerY.equalTo(self.titleView);
        }];
        
        [self.recBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleView);
            make.centerX.equalTo(self.titleView).offset(-24);
        }];
        
        [self.cityBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.titleView);
            make.centerX.equalTo(self.titleView).offset(24);
        }];
        
        [self.refreshView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.view);
            make.top.equalTo(self.view).offset(GK_SAVEAREA_BTM + 20.0f);
            make.height.mas_equalTo(44.0f);
        }];
        
        [self.refreshLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.refreshView);
        }];
        
        // 模拟加载
        GKBallLoadingView *loadingView = [GKBallLoadingView loadingViewInView:self.view];
        [loadingView startLoading];
        
        @weakify(self);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            @strongify(self);
            
            [loadingView stopLoading];
            [loadingView removeFromSuperview];
            
            [self.videoView.viewModel refreshNewListWithSuccess:^(NSArray * _Nonnull list) {
                [self.videoView setModels:list index:0];
            } failure:^(NSError * _Nonnull error) {
                
            }];
        });
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

- (void)shootClick:(id)sender {
    if ([self.delegate respondsToSelector:@selector(playerVCDidClickShoot:)]) {
        [self.delegate playerVCDidClickShoot:self];
    }
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
    
    GKDYVideoModel *model = videoModel;
    
    model.isAgree = !model.isAgree;
    
    int agreeNum = model.agree_num.intValue;
    
    if (model.isAgree) {
        model.agree_num = [NSString stringWithFormat:@"%d", agreeNum + 1];
    }else {
        model.agree_num = [NSString stringWithFormat:@"%d", agreeNum - 1];
    }
    
    videoView.currentPlayView.model = videoModel;
}

- (void)videoView:(GKDYVideoView *)videoView didClickComment:(GKDYVideoModel *)videoModel {
    GKDYCommentView *commentView = [GKDYCommentView new];
    commentView.frame = CGRectMake(0, 0, GK_SCREEN_WIDTH, ADAPTATIONRATIO * 980.0f);
    
    GKSlidePopupView *popupView = [GKSlidePopupView popupViewWithFrame:[UIScreen mainScreen].bounds contentView:commentView];
    [popupView showFrom:[UIApplication sharedApplication].keyWindow completion:^{
        [commentView requestData];
    }];
}

- (void)videoView:(GKDYVideoView *)videoView didClickShare:(GKDYVideoModel *)videoModel {
    
}

- (void)videoView:(GKDYVideoView *)videoView didScrollIsCritical:(BOOL)isCritical {
    if ([self.delegate respondsToSelector:@selector(playerVC:controlView:isCritical:)]) {
        [self.delegate playerVC:self controlView:videoView.currentPlayView isCritical:isCritical];
    }
}

- (void)videoView:(GKDYVideoView *)videoView didPanWithDistance:(CGFloat)distance isEnd:(BOOL)isEnd {
    if (self.isRefreshing) return;
    
    if (isEnd) {
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.titleView.frame;
            frame.origin.y = kTitleViewY;
            self.titleView.frame = frame;
            self.refreshView.frame = frame;
            
            CGRect loadingFrame = self.loadingBgView.frame;
            loadingFrame.origin.y = kTitleViewY;
            self.loadingBgView.frame = loadingFrame;
            
            self.refreshView.alpha      = 0;
            self.titleView.alpha        = 1;
            self.loadingBgView.alpha    = 1;
        }];
        
        if (distance >= 2 * kTransitionCenter) { // 刷新
            self.searchBtn.hidden = YES;
            [self.refreshLoadingView startLoading];
            self.isRefreshing = YES;
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self.refreshLoadingView stopLoading];
                self.loadingBgView.alpha = 0;
                self.searchBtn.hidden = NO;
                self.isRefreshing = NO;
            });
        }else {
            self.loadingBgView.alpha = 0;
        }
    }else {
        if (distance < 0) {
            self.refreshView.alpha = 0;
            self.titleView.alpha = 1;
        }else if (distance > 0 && distance < kTransitionCenter) {
            CGFloat alpha = distance / kTransitionCenter;
            
            self.refreshView.alpha      = 0;
            self.titleView.alpha        = 1 - alpha;
            self.loadingBgView.alpha    = 0;
            
            // 位置改变
            CGRect frame = self.titleView.frame;
            frame.origin.y = kTitleViewY + distance;
            self.titleView.frame = frame;
            self.refreshView.frame = frame;
            
            CGRect loadingFrame = self.loadingBgView.frame;
            loadingFrame.origin.y = frame.origin.y;
            self.loadingBgView.frame = loadingFrame;
        }else if (distance >= kTransitionCenter && distance <= 2 * kTransitionCenter) {
            CGFloat alpha = (2 * kTransitionCenter - distance) / kTransitionCenter;
            
            self.refreshView.alpha      = 1 - alpha;
            self.titleView.alpha        = 0;
            self.loadingBgView.alpha    = 1 - alpha;
            
            // 位置改变
            CGRect frame = self.titleView.frame;
            frame.origin.y = kTitleViewY + distance;
            self.titleView.frame    = frame;
            self.refreshView.frame  = frame;
            
            CGRect loadingFrame = self.loadingBgView.frame;
            loadingFrame.origin.y = frame.origin.y;
            self.loadingBgView.frame = loadingFrame;
            
            [self.refreshLoadingView startLoadingWithProgress:(1 - alpha)];
        }else {
            self.titleView.alpha    = 0;
            self.refreshView.alpha  = 1;
            self.loadingBgView.alpha = 1;
            [self.refreshLoadingView startLoadingWithProgress:1];
        }
    }
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

- (UIButton *)shootBtn {
    if (!_shootBtn) {
        _shootBtn = [UIButton new];
        [_shootBtn setImage:[UIImage imageNamed:@"iconTitlebarSuipai"] forState:UIControlStateNormal];
        [_shootBtn setTitle:@"随拍" forState:UIControlStateNormal];
        [_shootBtn setTitleColor:GKColorGray(169) forState:UIControlStateNormal];
        _shootBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 8, 0, 0);
        [_shootBtn addTarget:self action:@selector(shootClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _shootBtn;
}

- (UIButton *)searchBtn {
    if (!_searchBtn) {
        _searchBtn = [UIButton new];
        [_searchBtn setImage:[[UIImage imageNamed:@"icHomeSearchPure"] changeImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
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

- (UIView *)refreshView {
    if (!_refreshView) {
        _refreshView = [UIView new];
        _refreshView.backgroundColor = [UIColor clearColor];
        _refreshView.alpha = 0.0f;
    }
    return _refreshView;
}

- (UILabel *)refreshLabel {
    if (!_refreshLabel) {
        _refreshLabel = [UILabel new];
        _refreshLabel.font = [UIFont systemFontOfSize:16.0f];
        _refreshLabel.text = @"下拉刷新内容";
        _refreshLabel.textColor = [UIColor whiteColor];
    }
    return _refreshLabel;
}

- (UIView *)loadingBgView {
    if (!_loadingBgView) {
        _loadingBgView = [UIView new];
        _loadingBgView.backgroundColor = [UIColor clearColor];
        _loadingBgView.alpha = 0.0f;
    }
    return _loadingBgView;
}

@end
