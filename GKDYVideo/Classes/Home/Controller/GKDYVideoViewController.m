//
//  GKDYVideoViewController.m
//  GKDYVideo
//
//  Created by gaokun on 2019/7/3.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKDYVideoViewController.h"
#import "GKDYCommentView.h"
#import "GKSlidePopupView.h"

@interface GKDYVideoViewController ()<GKDYVideoViewDelegate, GKViewControllerPopDelegate>

@property (nonatomic, strong) UIButton              *backBtn;

@property (nonatomic, strong) NSArray               *videos;
@property (nonatomic, assign) NSInteger             playIndex;

@property (nonatomic, assign) CGPoint               vcCenter;

@property (nonatomic, strong) UIPercentDrivenInteractiveTransition  *interactiveTransition;

@end

@implementation GKDYVideoViewController

- (instancetype)initWithVideos:(NSArray *)videos index:(NSInteger)index {
    if (self = [super init]) {
        self.videos = videos;
        self.playIndex = index;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    self.gk_navigationBar.hidden = YES;
    self.gk_statusBarHidden = YES;
    self.gk_interactivePopDisabled = YES;
    
    [self.view addSubview:self.videoView];
    [self.view addSubview:self.backBtn];
    
    [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
    
    [self.backBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view).offset(15.0f);
        make.top.equalTo(self.view).offset(GK_SAVEAREA_TOP + 20.0f);
        make.width.height.mas_equalTo(44.0f);
    }];
    
    // 设置播放数据
    [self.videoView setModels:self.videos index:self.playIndex];
    
    self.vcCenter = self.view.center;
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] init];
    [pan addTarget:self action:@selector(panGestureRecognizerAction:)];
    [self.view addGestureRecognizer:pan];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    self.gk_popDelegate = self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.videoView resume];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    
    self.gk_popDelegate = nil;
    
    [self.videoView pause];
}

- (void)dealloc {
    [self.videoView destoryPlayer];
}

- (void)backClick:(id)sender {
//    [self.navigationController popViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)panGestureRecognizerAction:(UIPanGestureRecognizer *)pan {
    CGPoint translation = [pan translationInView:self.view];
    
    CGFloat process = [pan translationInView:self.view].x / [UIScreen mainScreen].bounds.size.width;
    process = MIN(1.0f, (MAX(0.0f, process)));
    
    if (pan.state == UIGestureRecognizerStateBegan) {
        self.interactiveTransition = [UIPercentDrivenInteractiveTransition new];
    }else if (pan.state == UIGestureRecognizerStateChanged) {
        CGFloat progress = translation.x / [UIScreen mainScreen].bounds.size.width;
        progress = fminf(fmaxf(progress, 0.0f), 1.0f);
        
        CGFloat ratio = 1.0f - progress * 0.5f;
        self.view.center = CGPointMake(self.vcCenter.x + translation.x * ratio, self.vcCenter.y + translation.y * ratio);
        NSLog(@"%@", NSStringFromCGPoint(self.view.center));
        self.view.transform = CGAffineTransformMakeScale(ratio, ratio);
        
        [self.interactiveTransition updateInteractiveTransition:process];
    }else if (pan.state == UIGestureRecognizerStateEnded || pan.state == UIGestureRecognizerStateCancelled) {
        if (process > 0.5) {
            [self.navigationController popViewControllerAnimated:YES];
            [self.interactiveTransition finishInteractiveTransition];
        }else {
            [self.interactiveTransition cancelInteractiveTransition];
        }
        self.interactiveTransition = nil;
    }
}

#pragma mark - GKDYVideoViewDelegate
- (void)videoView:(GKDYVideoView *)videoView didClickIcon:(GKDYVideoModel *)videoModel {
    
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
    videoView.currentPlayView.model = model;
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

#pragma mark - 懒加载
- (GKDYVideoView *)videoView {
    if (!_videoView) {
        _videoView = [[GKDYVideoView alloc] initWithVC:self isPushed:YES];
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

@end
