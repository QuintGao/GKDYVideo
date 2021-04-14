//
//  GKDYTabBar.m
//  GKDYVideo
//
//  Created by gaokun on 2019/5/8.
//  Copyright © 2019 QuintGao. All rights reserved.
//

#import "GKDYTabBar.h"
#import <GKNavigationBar/UIImage+GKNavigationBar.h>

@interface GKDYTabBar()

@property (nonatomic, strong) UIButton  *publishBtn;

@end

@implementation GKDYTabBar

- (instancetype)init {
    if (self = [super init]) {
        [self addSubview:self.publishBtn];
        [self showLine];
    }
    return self;
}

- (void)setStyle:(GKDYTabBarStyle)style {
    _style = style;
    
    if (style == GKDYTabBarStyleTransparent) {
        [self setBackgroundImage:[UIImage gk_imageWithColor:UIColor.clearColor size:CGSizeMake(SCREEN_WIDTH, TABBAR_HEIGHT)]];
    }else if (style == GKDYTabBarStyleTranslucent) {
        [self setBackgroundImage:[UIImage gk_imageWithColor:[UIColor colorWithWhite:0 alpha:0.8] size:CGSizeMake(SCREEN_WIDTH, TABBAR_HEIGHT)]];
    }
}

- (void)showLine {
    self.shadowImage = [UIImage gk_imageWithColor:[UIColor colorWithWhite:1.0f alpha:0.2f] size:CGSizeMake(SCREEN_WIDTH, 0.5f)];
}

- (void)hideLine {
    self.shadowImage = [UIImage gk_imageWithColor:[UIColor clearColor] size:CGSizeMake(SCREEN_WIDTH, 0.5f)];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat width = CGRectGetWidth(self.bounds);
    
    CGFloat btnX = 0;
    CGFloat btnY = 0;
    CGFloat btnW = width / 5;
    CGFloat btnH = 0;
    
    self.publishBtn.frame = CGRectMake(0, 0, btnW, 49);
    self.publishBtn.center = CGPointMake(width * 0.5f, 49 * 0.5f);
    
    NSInteger index = 0;
    for (UIControl *button in self.subviews) {
        if (![button isKindOfClass:[UIControl class]] || button == self.publishBtn) {
            continue;
        }
        
        // 计算btnX
        btnX = btnW * (index > 1 ? index + 1 : index);
        // 这里高度不能设置为tabbar的高度，因为iOS11 tabbar高度变化了
        btnH = button.frame.size.height;
        
        // 设置frame
        button.frame = CGRectMake(btnX, btnY, btnW, btnH);
        
        // 增加索引
        index ++;
    }
}

#pragma mark - 懒加载
- (UIButton *)publishBtn {
    if (!_publishBtn) {
        _publishBtn = [UIButton new];
        [_publishBtn setImage:[UIImage imageNamed:@"btn_home_add"] forState:UIControlStateNormal];
    }
    return _publishBtn;
}

@end
