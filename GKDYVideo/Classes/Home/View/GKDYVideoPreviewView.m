//
//  GKDYVideoPreviewView.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/22.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYVideoPreviewView.h"
#import "GKDYTools.h"
#import <ZFPlayer/ZFAVPlayerManager.h>

@interface ZFAVPlayerManager (GKCategory)

- (void)thumbnailImageAtTime:(NSTimeInterval)time completion:(void(^)(UIImage *_Nullable image))completion;

@end

@implementation ZFAVPlayerManager (GKCategory)

- (void)thumbnailImageAtTime:(NSTimeInterval)time completion:(void (^)(UIImage * _Nullable))completion {
    CMTime expectedTime = CMTimeMakeWithSeconds(time, NSEC_PER_SEC);
    
    AVAssetImageGenerator *imageGenerator = [self valueForKey:@"imageGenerator"];
    
    [imageGenerator generateCGImagesAsynchronouslyForTimes:@[[NSValue valueWithCMTime:expectedTime]] completionHandler:^(CMTime requestedTime, CGImageRef  _Nullable image, CMTime actualTime, AVAssetImageGeneratorResult result, NSError * _Nullable error) {
        if (image) {
            UIImage *finalImage = [UIImage imageWithCGImage:image];
            !completion ?: completion(finalImage);
        }else {
            !completion ?: completion(nil);
        }
    }];
}

@end

@interface GKDYVideoPreviewView()

@property (nonatomic, strong) UIImageView *imageView;

@property (nonatomic, strong) UILabel *timeLabel;

@end

@implementation GKDYVideoPreviewView

- (instancetype)init {
    if (self = [super init]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    [self addSubview:self.imageView];
    [self addSubview:self.timeLabel];
    
    [self.imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.top.right.equalTo(self);
        make.height.mas_equalTo(120*9/16);
    }];
    
    [self.timeLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imageView.mas_bottom).offset(20);
        make.centerX.equalTo(self);
    }];
}

- (void)setPreviewValue:(float)value {
    NSString *currentTime = [GKDYTools convertTimeSecond:self.player.totalTime * value];
    NSString *totalTime = [GKDYTools convertTimeSecond:self.player.totalTime];
    self.timeLabel.text = [NSString stringWithFormat:@"%@ / %@", currentTime, totalTime];
    
    ZFAVPlayerManager *manager = (ZFAVPlayerManager *)self.player.currentPlayerManager;
    
    @weakify(self);
    [manager thumbnailImageAtTime:self.player.totalTime * value completion:^(UIImage * _Nullable image) {
        if (image) {
            @strongify(self);
            dispatch_async(dispatch_get_main_queue(), ^{
                self.imageView.image = image;
            });
        }
    }];
}

#pragma mark - Lazy
- (UIImageView *)imageView {
    if (!_imageView) {
        _imageView = [[UIImageView alloc] init];
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.layer.cornerRadius = 5;
        _imageView.layer.masksToBounds = YES;
    }
    return _imageView;
}

- (UILabel *)timeLabel {
    if (!_timeLabel) {
        _timeLabel = [[UILabel alloc] init];
        _timeLabel.font = [UIFont systemFontOfSize:15];
        _timeLabel.textColor = UIColor.whiteColor;
    }
    return _timeLabel;
}

@end
