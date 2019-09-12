//
//  GKDYScaleVideoView.m
//  GKDYVideo
//
//  Created by gaokun on 2019/7/30.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKDYScaleVideoView.h"
#import "GKDYVideoView.h"
#import "GKDYListCollectionViewCell.h"

@interface GKDYScaleVideoView()

@property (nonatomic, weak) GKDYPersonalViewController  *vc;

@property (nonatomic, assign) BOOL                      interacting;

@end

@implementation GKDYScaleVideoView

- (instancetype)initWithVC:(GKDYPersonalViewController *)vc videos:(NSArray *)videos index:(NSInteger)index {
    if (self = [super init]) {
        self.backgroundColor = [UIColor blackColor];
        self.vc = vc;
        
        [self addSubview:self.videoView];
        
        UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] init];
        [panGesture addTarget:self action:@selector(handlePanGesture:)];
        [self addGestureRecognizer:panGesture];
        
        [self.videoView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(self);
        }];
        
        // 设置数据
        [self.videoView setModels:videos index:index];
    }
    return self;
}

- (void)dealloc {
    NSLog(@"GKDYScaleVideoView--%s", __func__);
    [self.videoView destoryPlayer];
}

- (void)backClick:(id)sender {
    self.vc.gk_statusBarHidden = NO;
    
    [self dismiss];
}

- (void)handlePanGesture:(UIPanGestureRecognizer *)panGesture {
    CGPoint translation = [panGesture translationInView:panGesture.view.superview];
    if (!self.interacting && (translation.x < 0 || translation.y < 0 || translation.x < translation.y)) return;
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            // 修复当从右侧向左侧滑动时的bug，避免开始的时候从右向左滑动
            CGPoint vel = [panGesture velocityInView:panGesture.view];
            if (!self.interacting && vel.x < 0) {
                self.interacting = NO;
                return;
            }
            self.interacting = YES;
            self.vc.gk_statusBarHidden = NO;
            [self.videoView pause];
        }
            break;
        case UIGestureRecognizerStateChanged: {
            CGFloat progress = translation.x / [UIScreen mainScreen].bounds.size.width;
            progress = fminf(fmaxf(progress, 0.0f), 1.0f);
            
            CGFloat ratio = 1.0f - progress * 0.5f;
            self.videoView.center = CGPointMake(self.vc.view.center.x + translation.x * ratio, self.vc.view.center.y + translation.y * ratio);
            self.videoView.transform = CGAffineTransformMakeScale(ratio, ratio);
            
            CGFloat percent = 1 - fabs(translation.x) / [UIScreen mainScreen].bounds.size.width;
            self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:percent];
        }
            break;
        case UIGestureRecognizerStateCancelled:
        case UIGestureRecognizerStateEnded: {
            CGFloat progress = translation.x / [UIScreen mainScreen].bounds.size.width;
            progress = fminf(fmaxf(progress, 0.0f), 1.0f);
            if (progress < 0.2) { // 恢复
                self.vc.gk_statusBarHidden = YES;
                self.vc.gk_interactivePopDisabled = YES;
                
                [UIView animateWithDuration:0.25
                                      delay:0
                                    options:UIViewAnimationOptionCurveEaseOut
                                 animations:^{
                                     self.videoView.center = self.vc.view.center;
                                     self.videoView.transform = CGAffineTransformMakeScale(1.0f, 1.0f);
                                 } completion:^(BOOL finished) {
                                     self.interacting = NO;
                                     
                                     [self.videoView resume];
                                     self.backgroundColor = [UIColor blackColor];
                                 }];
            }else { // 消失
                [self dismiss];
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)show {
    // 隐藏状态栏及禁用手势
    self.vc.gk_statusBarHidden = YES;
    self.vc.gk_interactivePopDisabled = YES;
    
    // 添加视图
    [self.vc.view addSubview:self];
    
    // 获取当前显示的列表控制器
    GKDYListViewController *listVC = self.vc.currentListVC;
    
    // 获取当前点击的cell
    GKDYListCollectionViewCell *cell = (GKDYListCollectionViewCell *)[listVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:listVC.selectedIndex inSection:0]];
    
    CGRect originalFrame = [listVC.collectionView convertRect:cell.frame toView:self.vc.view];
    CGRect finalFrame = self.vc.view.frame;
    
    self.frame = finalFrame;
    
    self.center = CGPointMake(originalFrame.origin.x + originalFrame.size.width * 0.5, originalFrame.origin.y + originalFrame.size.height * 0.5);
    self.transform = CGAffineTransformMakeScale(originalFrame.size.width / finalFrame.size.width, originalFrame.size.height / finalFrame.size.height);
    
    // 显示动画
    [UIView animateWithDuration:0.3
                          delay:0
         usingSpringWithDamping:0.8
          initialSpringVelocity:1
                        options:UIViewAnimationOptionLayoutSubviews
                     animations:^{
                         self.center = CGPointMake(finalFrame.origin.x + finalFrame.size.width * 0.5, finalFrame.origin.y + finalFrame.size.height * 0.5);
                         self.transform = CGAffineTransformMakeScale(1, 1);
                     } completion:nil];
}

- (void)dismiss {
    // 获取当前显示的控制器
    GKDYListViewController *listVC = self.vc.currentListVC;
    
    // 获取cell
    UICollectionViewCell *cell = [listVC.collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:self.videoView.currentPlayIndex inSection:0]];
    
    UIView *snapShotView;
    CGRect finalFrame = CGRectZero;
    
    if (cell) {
        snapShotView = [cell snapshotViewAfterScreenUpdates:NO];
        snapShotView.frame = self.videoView.frame;
        finalFrame = [listVC.collectionView convertRect:cell.frame toView:self.vc.view];
    }else {
        snapShotView = [self.videoView snapshotViewAfterScreenUpdates:NO];
        finalFrame = CGRectMake((SCREEN_WIDTH - 5) * 0.5f, (SCREEN_HEIGHT - 5) * 0.5f, 5, 5);
    }
    
    [self addSubview:snapShotView];
    
    self.videoView.hidden = YES;
    [self.videoView pause];
    self.backgroundColor = [UIColor clearColor];
    
    // 隐藏动画
    [UIView animateWithDuration:0.25 delay:0 usingSpringWithDamping:0.8 initialSpringVelocity:0.2 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        snapShotView.frame = finalFrame;
    } completion:^(BOOL finished) {
        [snapShotView removeFromSuperview];
        
        self.vc.gk_interactivePopDisabled = NO;
        
        [self removeFromSuperview];
    }];
}

#pragma mark - 懒加载
- (GKDYVideoView *)videoView {
    if (!_videoView) {
        _videoView = [[GKDYVideoView alloc] initWithVC:self.vc isPushed:YES];
        [_videoView.backBtn addTarget:self action:@selector(backClick:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _videoView;
}

@end
