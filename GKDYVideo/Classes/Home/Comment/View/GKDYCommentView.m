//
//  GKDYCommentView.m
//  GKDYVideo
//
//  Created by QuintGao on 2019/5/1.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKDYCommentView.h"
#import "GKBallLoadingView.h"
#import "GKDYCommentModel.h"
#import "GKDYCommentCell.h"
#import <MJRefresh/MJRefresh.h>
#import "GKPopupController.h"
#import "GKDYCommentControlView.h"

@interface GKDYCommentView()<UITableViewDataSource, UITableViewDelegate, GKPopupProtocol>

@property (nonatomic, strong) UIVisualEffectView    *effectView;
@property (nonatomic, strong) UIView                *topView;
@property (nonatomic, strong) UILabel               *countLabel;

@property (nonatomic, strong) UIButton              *unfoldBtn;

@property (nonatomic, strong) UIButton              *closeBtn;

@property (nonatomic, strong) UITableView           *tableView;

@property (nonatomic, assign) NSInteger             count;

@property (nonatomic, strong) GKDYCommentModel      *commentModel;

@property (nonatomic, strong) GKDYVideoModel        *model;

@property (nonatomic, assign) NSInteger pn;

@property (nonatomic, weak) GKBallLoadingView *loadingView;

@property (nonatomic, strong) NSMutableArray *dataSources;

@property (nonatomic, weak) GKDYVideoPortraitCell *cell;

@property (nonatomic, assign) CGFloat playerW;
@property (nonatomic, assign) CGFloat playerH;
@property (nonatomic, assign) CGRect playerFrame;

@end

@implementation GKDYCommentView

- (instancetype)init {
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        
        [self addSubview:self.topView];
        [self addSubview:self.effectView];
        [self addSubview:self.countLabel];
        [self addSubview:self.unfoldBtn];
        [self addSubview:self.closeBtn];
        [self addSubview:self.tableView];
        
        [self.topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.top.right.equalTo(self);
            make.height.mas_equalTo(ADAPTATIONRATIO * 100.0f);
        }];
        
        [self.effectView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        [self.countLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.center.equalTo(self.topView);
        }];
        
        [self.unfoldBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.closeBtn.mas_left).offset(-ADAPTATIONRATIO * 32);
            make.centerY.equalTo(self.closeBtn);
            make.width.height.mas_equalTo(ADAPTATIONRATIO * 36);
        }];
        
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView);
            make.right.equalTo(self).offset(-ADAPTATIONRATIO * 32.0f);
            make.width.height.mas_equalTo(ADAPTATIONRATIO * 36.0f);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(self.topView.mas_bottom);
        }];
        
        self.pn = 1;
        
        @weakify(self);
        self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingBlock:^{
            @strongify(self);
            self.pn ++;
            [self requestData];
        }];
    }
    return self;
}

- (void)showWithCell:(GKDYVideoPortraitCell *)cell containerView:(UIView *)containerView {
    self.cell = cell;
    self.containerView = containerView;
    self.player = cell.manager.player;
    
    CGFloat originH = cell.coverImgView.frame.size.height;
    
    GKDYCommentControlView *controlView = [[GKDYCommentControlView alloc] init];
    self.player.controlView = controlView;
    self.player.containerView = self.containerView;
    
    // 防止动画异常
    ZFPlayerView *playView = self.player.currentPlayerManager.view;
    playView.playerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    playView.coverImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    CGSize videoSize = self.player.currentPlayerManager.presentationSize;
    if (CGSizeEqualToSize(videoSize, CGSizeZero)) {
        videoSize = cell.coverImgView.frame.size;
    }
    
    CGRect frame = playView.frame;
    frame.size.height = frame.size.width * videoSize.height / videoSize.width;
    frame.origin.y = (self.containerView.bounds.size.height - frame.size.height) / 2;
    playView.frame = frame;
    self.playerW = frame.size.width;
    self.playerH = frame.size.height;
    
    GKPopupController *controller = [[GKPopupController alloc] initWithContentView:self];
    controller.bgColor = UIColor.clearColor;
    controller.delegate = self;
    [controller show];
}

- (void)refreshDataWithModel:(GKDYVideoModel *)model {
    if (![self.model.video_id isEqualToString:model.video_id]) {
        [self.dataSources removeAllObjects];
        [self.tableView reloadData];
    }
    self.countLabel.text = [NSString stringWithFormat:@"%@条评论", model.comment];
}

- (void)requestDataWithModel:(GKDYVideoModel *)model {
    if ([self.model.video_id isEqualToString:model.video_id]) {
        if (self.model.isRequest) {
            return;
        }
        
        if (self.model.requested) {
            return;
        }
    }
    self.model = model;
    
    self.model.isRequest = YES;
    
    [self.dataSources removeAllObjects];
    [self.tableView reloadData];
    
    GKBallLoadingView *loadingView = [GKBallLoadingView loadingViewInView:self.tableView];
    [loadingView startLoading];
    self.loadingView = loadingView;
    
    [self requestData];
}

- (void)requestData {
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    NSString *url = [NSString stringWithFormat:@"https://haokan.baidu.com/haokan/ui-web/v2/comment/get?rn=10&url_key=%@&pn=%zd", self.model.video_id, self.pn];
    
    @weakify(self);
    [manager GET:url parameters:nil headers:nil progress:nil success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        @strongify(self);
        if (self.loadingView) {
            [self.loadingView stopLoading];
            [self.loadingView removeFromSuperview];
            self.loadingView = nil;
        }
        
        self.model.isRequest = NO;
        self.model.requested = YES;
        
        self.commentModel = [GKDYCommentModel yy_modelWithDictionary:responseObject[@"data"]];
        self.countLabel.text = [NSString stringWithFormat:@"%@条评论", self.commentModel.comment_count];
        [self.dataSources addObjectsFromArray:self.commentModel.list];
        [self.tableView reloadData];
        
        if (self.commentModel.is_over) {
            [self.tableView.mj_footer endRefreshingWithNoMoreData];
        }else {
            [self.tableView.mj_footer endRefreshing];
        }
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        @strongify(self);
        self.model.isRequest = NO;
        if (self.loadingView) {
            [self.loadingView stopLoading];
            [self.loadingView removeFromSuperview];
            self.loadingView = nil;
        }
    }];
}

#pragma mark - <UITableViewDataSource, UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    self.tableView.mj_footer.hidden = self.dataSources.count == 0;
    return self.dataSources.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GKDYCommentCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GKDYCommentCell" forIndexPath:indexPath];
    [cell loadData:self.dataSources[indexPath.row]];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return [GKDYCommentCell heightWithModel:self.dataSources[indexPath.row]];
}

#pragma mark - Action
- (void)unfoldAction {
    self.unfoldBtn.selected = !self.unfoldBtn.selected;
    [self.popupController refreshContentHeight];
}

- (void)closeAction {
    [self.popupController dismiss];
}

#pragma mark - GKPopupProtocol
@synthesize popupController;

- (CGFloat)contentHeight {
    if (self.unfoldBtn.selected) {
        return (SCREEN_HEIGHT - GK_SAFEAREA_TOP);
    }else {
        CGFloat width = self.containerView.bounds.size.width;
        CGFloat height = width * 9 / 16;
        return (SCREEN_HEIGHT - GK_SAFEAREA_TOP - height);
    }
}

- (void)contentViewWillShow {
    if ([self.delegate respondsToSelector:@selector(commentView:showOrHide:)]) {
        [self.delegate commentView:self showOrHide:YES];
    }
    [self refreshDataWithModel:self.videoModel];
}

- (void)contentViewDidShow {
    [self requestDataWithModel:self.videoModel];
}

- (void)contentViewDidDismiss {
    self.unfoldBtn.selected = NO;
    self.player.controlView = self.cell.portraitView;
    self.player.containerView = self.cell.coverImgView;
    [self.containerView removeFromSuperview];
    self.containerView = nil;
    if ([self.delegate respondsToSelector:@selector(commentView:showOrHide:)]) {
        [self.delegate commentView:self showOrHide:NO];
    }
}

- (void)contentViewShowAnimation {
    UIView *playView = self.player.currentPlayerManager.view;
    CGRect frame = playView.frame;
    frame.origin.y = GK_SAFEAREA_TOP;
    frame.size.height = SCREEN_HEIGHT - self.contentHeight - GK_SAFEAREA_TOP;
    frame.size.width = frame.size.height * self.playerW / self.playerH;
    
    if (frame.size.width > self.containerView.bounds.size.width) {
        frame.size.width = self.containerView.bounds.size.width;
        frame.size.height = frame.size.width * self.playerH / self.playerW;
    }
    
    playView.frame = frame;
    
    CGPoint center = playView.center;
    center.x = self.containerView.bounds.size.width * 0.5;
    playView.center = center;
}

- (void)contentViewDismissAnimation {
    UIView *playView = self.player.currentPlayerManager.view;
    CGRect frame = playView.frame;
    frame.size.width = self.containerView.bounds.size.width;
    frame.size.height = frame.size.width * self.playerH / self.playerW;
    frame.origin.y = (self.containerView.bounds.size.height - frame.size.height) / 2;
    frame.origin.x = 0;
    playView.frame = frame;
}

- (void)contentViewRefreshAnimation {
    UIView *playView = self.player.currentPlayerManager.view;
    CGRect frame = playView.frame;
    frame.origin.y = GK_SAFEAREA_TOP;
    if (self.unfoldBtn.selected) {
        frame.size.width = 1;
        frame.size.height = 1;
    }else {
        frame.size.height = SCREEN_HEIGHT - self.contentHeight - GK_SAFEAREA_TOP;
        frame.size.width = frame.size.height * self.playerW / self.playerH;
        
        if (frame.size.width > self.containerView.bounds.size.width) {
            frame.size.width = self.containerView.bounds.size.width;
            frame.size.height = frame.size.width * self.playerH / self.playerW;
        }
    }
    playView.frame = frame;
    
    CGPoint center = playView.center;
    center.x = self.containerView.bounds.size.width / 2;
    playView.center = center;
}

- (void)panSlideChangeWithRatio:(CGFloat)ratio {
    CGFloat minH = SCREEN_HEIGHT - self.contentHeight - GK_SAFEAREA_TOP;
    CGFloat minW = minH * self.playerW / self.playerH;
    CGFloat minY = GK_SAFEAREA_TOP;
    CGFloat height = (self.containerView.bounds.size.width * self.playerH / self.playerW);
    CGFloat maxY = (self.containerView.bounds.size.height - height) / 2;
    
    UIView *playView = self.player.currentPlayerManager.view;
    CGRect frame = playView.frame;
    frame.origin.y = MAX(minY, minY + (maxY - minY) * ratio);
    frame.size.width = MAX(minW, minW + (self.containerView.bounds.size.width - minW) * ratio);
    frame.size.height = frame.size.width * self.playerH / self.playerW;
    playView.frame = frame;
    
    CGPoint center = playView.center;
    center.x = self.containerView.bounds.size.width * 0.5;
    playView.center = center;
}

#pragma mark - 懒加载
- (UIVisualEffectView *)effectView {
    if (!_effectView) {
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
        _effectView = [[UIVisualEffectView alloc] initWithEffect:blur];
    }
    return _effectView;
}

- (UIView *)topView {
    if (!_topView) {
        _topView = [UIView new];
        _topView.backgroundColor = GKColorGray(23);
        
        CGRect frame = CGRectMake(0, 0, SCREEN_WIDTH, ADAPTATIONRATIO * 100.0f);
        //绘制圆角 要设置的圆角 使用“|”来组合
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:frame byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(5, 5)];
        
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        //设置大小
        maskLayer.frame = frame;
        
        //设置图形样子
        maskLayer.path = maskPath.CGPath;
        
        _topView.layer.mask = maskLayer;
    }
    return _topView;
}

- (UILabel *)countLabel {
    if (!_countLabel) {
        _countLabel = [UILabel new];
        _countLabel.font = [UIFont systemFontOfSize:17.0f];
        _countLabel.textColor = [UIColor whiteColor];
    }
    return _countLabel;
}

- (UIButton *)unfoldBtn {
    if (!_unfoldBtn) {
        _unfoldBtn = [UIButton new];
        [_unfoldBtn setImage:[UIImage imageNamed:@"arrow_close"] forState:UIControlStateNormal];
        [_unfoldBtn setImage:[UIImage imageNamed:@"arrow_open"] forState:UIControlStateSelected];
        [_unfoldBtn addTarget:self action:@selector(unfoldAction) forControlEvents:UIControlEventTouchUpInside];
//        _unfoldBtn.hidden = YES;
    }
    return _unfoldBtn;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton new];
        [_closeBtn setImage:[UIImage gk_changeImage:[UIImage imageNamed:@"close"] color:[UIColor whiteColor]] forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        [_tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cell"];
        _tableView.rowHeight = ADAPTATIONRATIO * 120.0f;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        _tableView.estimatedRowHeight = 0;
        _tableView.backgroundColor = [UIColor clearColor];
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
        [_tableView registerClass:GKDYCommentCell.class forCellReuseIdentifier:@"GKDYCommentCell"];
    }
    return _tableView;
}

- (NSMutableArray *)dataSources {
    if (!_dataSources) {
        _dataSources = [NSMutableArray array];
    }
    return _dataSources;
}

@end
