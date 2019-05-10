//
//  GKDYCommentView.m
//  GKDYVideo
//
//  Created by QuintGao on 2019/5/1.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKDYCommentView.h"
#import "UIImage+GKCategory.h"
#import "GKBallLoadingView.h"

@interface GKDYCommentView()<UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) UIVisualEffectView    *effectView;
@property (nonatomic, strong) UIView                *topView;
@property (nonatomic, strong) UILabel               *countLabel;
@property (nonatomic, strong) UIButton              *closeBtn;

@property (nonatomic, strong) UITableView           *tableView;

@property (nonatomic, assign) NSInteger             count;

@end

@implementation GKDYCommentView

- (instancetype)init {
    if (self = [super init]) {
        
        self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.7];
        
        [self addSubview:self.topView];
        [self addSubview:self.effectView];
        [self addSubview:self.countLabel];
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
        
        [self.closeBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerY.equalTo(self.topView);
            make.right.equalTo(self).offset(-ADAPTATIONRATIO * 16.0f);
            make.width.height.mas_equalTo(ADAPTATIONRATIO * 36.0f);
        }];
        
        [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.bottom.equalTo(self);
            make.top.equalTo(self.topView.mas_bottom);
        }];
        
        self.countLabel.text = [NSString stringWithFormat:@"%zd条评论", self.count];
    }
    return self;
}

- (void)requestData {
    GKBallLoadingView *loadingView = [GKBallLoadingView loadingViewInView:self.tableView];
    [loadingView startLoading];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.0f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [loadingView stopLoading];
        [loadingView removeFromSuperview];
        
        self.count = 30;
        self.countLabel.text = [NSString stringWithFormat:@"%zd条评论", self.count];
        [self.tableView reloadData];
    });
}

#pragma mark - <UITableViewDataSource, UITableViewDelegate>
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = [NSString stringWithFormat:@"这是第%zd条评论", indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    return cell;
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

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [UIButton new];
        [_closeBtn setImage:[[UIImage imageNamed:@"close"] changeImageWithColor:[UIColor whiteColor]] forState:UIControlStateNormal];
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
        } else {
            // Fallback on earlier versions
        }
    }
    return _tableView;
}

@end
