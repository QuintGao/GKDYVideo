//
//  GKRedPlayerManager.m
//  GKDYVideo
//
//  Created by QuintGao on 2024/4/28.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKRedPlayerManager.h"
#import "GKRedPreloadManager.h"

@import RedPlayer;
@import MediaPlayer;

@interface GKRedPlayerManager()

@property (nonatomic, strong) id<RedMediaPlayback> player;

@property (nonatomic, assign) BOOL isSeeking;
@property (nonatomic, copy) void(^seekCompletion)(BOOL);

@property (nonatomic, assign) BOOL needPlay;

@end

@implementation GKRedPlayerManager {
    dispatch_source_t _timer;
}

@synthesize view = _view;
@synthesize currentTime = _currentTime;
@synthesize totalTime = _totalTime;
@synthesize playerPlayTimeChanged = _playerPlayTimeChanged;
@synthesize playerBufferTimeChanged = _playerBufferTimeChanged;
@synthesize playerDidToEnd = _playerDidToEnd;
@synthesize bufferTime = _bufferTime;
@synthesize playState = _playState;
@synthesize loadState = _loadState;
@synthesize assetURL = _assetURL;
@synthesize playerPrepareToPlay = _playerPrepareToPlay;
@synthesize playerReadyToPlay = _playerReadyToPlay;
@synthesize playerPlayStateChanged = _playerPlayStateChanged;
@synthesize playerLoadStateChanged = _playerLoadStateChanged;
@synthesize seekTime = _seekTime;
@synthesize muted = _muted;
@synthesize volume = _volume;
@synthesize presentationSize = _presentationSize;
@synthesize isPlaying = _isPlaying;
@synthesize rate = _rate;
@synthesize isPreparedToPlay = _isPreparedToPlay;
@synthesize shouldAutoPlay = _shouldAutoPlay;
@synthesize scalingMode = _scalingMode;
@synthesize playerPlayFailed = _playerPlayFailed;
@synthesize presentationSizeChanged = _presentationSizeChanged;

- (instancetype)init {
    if (self = [super init]) {
        _scalingMode = ZFPlayerScalingModeAspectFit;
        _shouldAutoPlay = YES;
    }
    return self;
}

- (void)prepareToPlay {
    if (!_assetURL) return;
    _isPreparedToPlay = YES;
    [self initializePlayer];
    if (self.shouldAutoPlay) {
        [self play];
    }
    self.loadState = ZFPlayerLoadStatePrepare;
    if (self.playerPrepareToPlay) self.playerPrepareToPlay(self, self.assetURL);
}

- (void)initializePlayer {
    if (self.player) return;
    [RedPlayerController setLogCallbackLevel:k_RED_LOG_ERROR];
    [RedPlayerController setLogCallback:^(RedLogLevel logLevel, NSString *tagInfo, NSString *logContent) {
        NSLog(@"[%d]=[%@]-%@", logLevel, tagInfo, logContent);
    }];
    self.player = [[RedPlayerController alloc] initWithContentURL:self.assetURL withRenderType:RedRenderTypeOpenGL];
    self.player.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.player.shouldAutoplay = _shouldAutoPlay;
    self.player.notPauseGlviewBackground = NO;
    [self.player setEnableVTB:YES];
    [self.player setVideoCacheDir:[GKRedPreloadManager cachePath]];
    
    self.view.playerView = self.player.view;
    self.scalingMode = _scalingMode;
    
    [self addPlayerNotifications];
    [self.player prepareToPlay];
    
    // 创建定时器
    _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(_timer, DISPATCH_TIME_NOW, 0.5 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(_timer, ^{
        [self refreshTime];
    });
    dispatch_resume(_timer);
}

- (void)reloadPlayer {
    self.seekTime = self.currentTime;
    [self prepareToPlay];
}

- (void)play {
    if (!_isPreparedToPlay) {
        [self prepareToPlay];
    }else {
        if (self.player.isPreparedToPlay) {
            [self.player play];
            self.player.playbackRate = self.rate;
            self->_isPlaying = YES;
        }else {
            self.needPlay = YES;
        }
    }
}

- (void)pause {
    [self.player pause];
    self->_isPlaying = NO;
}

- (void)stop {
    [self removePlayerNotifications];
    if (_timer) {
        dispatch_source_cancel(_timer);
        _timer = nil;
    }
    self.loadState = ZFPlayerLoadStateUnknown;
    self.playState = ZFPlayerPlayStatePlayStopped;
    if (self.player) {
        [self.player shutdown];
        self.player = nil;
    }
    self.presentationSize = CGSizeZero;
    _isPlaying = NO;
    _assetURL = nil;
    _isPreparedToPlay = NO;
    self->_currentTime = 0;
    self->_totalTime = 0;
    self->_bufferTime = 0;
}

- (void)replay {
    [self play];
}

- (void)seekToTime:(NSTimeInterval)time completionHandler:(void (^)(BOOL))completionHandler {
    if (self.totalTime > 0) {
        self.seekCompletion = completionHandler;
        self.player.currentPlaybackTime = time;
    }else {
        self.seekTime = time;
    }
}

- (void)refreshTime {
    if (self.player.isPlaying) {
        if (self.player.currentPlaybackTime) {
            _currentTime = self.player.currentPlaybackTime;
        }
        if (self.player.duration) {
            _totalTime = self.player.duration;
        }
        self.playerPlayTimeChanged(self, _currentTime, _totalTime);
    }
    if (self.player.isSeekBuffering) {
        if (self.player.duration) {
            _bufferTime = self.player.duration * self.player.bufferingProgress;
        }else {
            _bufferTime = 0;
        }
        self.playerBufferTimeChanged(self, _bufferTime);
    }
}

#pragma mark Notifications
- (void)addPlayerNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(loadStateDidChange:) name:RedPlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackDidFinish:) name:RedPlayerPlaybackDidFinishNotification object:_player];;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(isPreparedToPlayDidChange:) name:RedMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playbackStateDidChange:) name:RedPlayerPlaybackStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playNaturalSizeAvailable:) name:RedPlayerNaturalSizeAvailableNotification object:_player];
}

- (void)removePlayerNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RedPlayerLoadStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RedPlayerPlaybackDidFinishNotification object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RedMediaPlaybackIsPreparedToPlayDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RedPlayerPlaybackStateDidChangeNotification object:_player];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:RedPlayerNaturalSizeAvailableNotification object:_player];
}

- (void)loadStateDidChange:(NSNotification *)notify {
    NSLog(@"[RedPlayer]-loadState%zd", _player.loadState);
    RedLoadState loadState = _player.loadState;
    if ((loadState & RedLoadStatePlaythroughOK) != 0) {
        self.loadState = ZFPlayerLoadStatePlaythroughOK;
        if (self.seekCompletion) {
            self.seekCompletion(YES);
        }
        self.seekCompletion = nil;
    }else if ((loadState & RedLoadStatePlayable) != 0) {
        self.loadState = ZFPlayerLoadStatePlayable;
        if (self.seekCompletion) {
            self.seekCompletion(YES);
        }
        self.seekCompletion = nil;
    }else if ((loadState & RedLoadStateStalled) != 0) {
        self.loadState = ZFPlayerLoadStateStalled;
    }else {
        self.loadState = ZFPlayerLoadStateUnknown;
    }
}

- (void)playbackDidFinish:(NSNotification *)notify {
    int reason = [[notify.userInfo valueForKey:RedPlayerPlaybackDidFinishReasonUserInfoKey] intValue];
    switch (reason) {
        case RedFinishReasonPlaybackEnded: {
            self.playState = ZFPlayerPlayStatePlayStopped;
            if (self.playerDidToEnd) {
                self.playerDidToEnd(self);
            }
        }
            break;
        case RedFinishReasonUserExited:
            self.playState = ZFPlayerPlayStatePlayFailed;
            break;
        case RedFinishReasonPlaybackError: {
            self.playState = ZFPlayerPlayStatePlayFailed;
            NSNumber *errorCode = [notify.userInfo valueForKey:RedPlayerPlaybackDidFinishErrorUserInfoKey];
            if (self.playerPlayFailed) {
                self.playerPlayFailed(self, errorCode);
            }
        }
            break;
            
        default:
            break;
    }
}

- (void)isPreparedToPlayDidChange:(NSNotification *)notify {
    if (self.player.isPreparedToPlay) {
        if (self.playerReadyToPlay) {
            self.playerReadyToPlay(self, self.assetURL);
        }
        if (self.needPlay) {
            [self play];
        }
    }
}

- (void)playbackStateDidChange:(NSNotification *)notify {
    switch (self.player.playbackState) {
        case RedPlaybackStateStopped:
            self.playState = ZFPlayerPlayStatePlayStopped;
            break;
        case RedPlaybackStatePlaying: {
            self.playState = ZFPlayerPlayStatePlaying;
        }
            break;
        case RedPlaybackStatePaused:
            self.playState = ZFPlayerPlayStatePaused;
            break;
        case RedPlaybackStateInterrupted:
            self.playState = ZFPlayerPlayStatePaused;
            break;
        case RedPlaybackStateSeekingForward:
        case RedPlaybackStateSeekingBackward: {
            NSLog(@"seeking");
        }
            break;
        default:
            break;
    }
}

- (void)playNaturalSizeAvailable:(NSNotification *)notify {
    self.presentationSize = self.player.naturalSize;
}

#pragma mark - getter
- (ZFPlayerView *)view {
    if (!_view) {
        _view = [[ZFPlayerView alloc] init];
    }
    return _view;
}

- (float)rate {
    return _rate == 0 ? 1 : _rate;
}

- (NSTimeInterval)totalTime {
    if (self.player.duration) {
        return self.player.duration;
    }
    return _totalTime;
}

- (NSTimeInterval)currentTime {
    if (self.player.currentPlaybackTime) {
        return self.player.currentPlaybackTime;
    }
    return _currentTime;
}

#pragma mark - setter
- (void)setPlayState:(ZFPlayerPlaybackState)playState {
    _playState = playState;
    if (self.playerPlayStateChanged) self.playerPlayStateChanged(self, playState);
}

- (void)setLoadState:(ZFPlayerLoadState)loadState {
    _loadState = loadState;
    if (self.playerLoadStateChanged) self.playerLoadStateChanged(self, loadState);
}

- (void)setAssetURL:(NSURL *)assetURL {
    if (self.player) [self stop];
    _assetURL = assetURL;
    [self prepareToPlay];
}

- (void)setRate:(float)rate {
    _rate = rate;
    if (self.player && fabs(_player.playbackRate) > 0.00001f) {
        self.player.playbackRate = rate;
    }
}

- (void)setMuted:(BOOL)muted {
    _muted = muted;
    [self.player setMute:muted];
}

- (void)setScalingMode:(ZFPlayerScalingMode)scalingMode {
    _scalingMode = scalingMode;
    self.view.scalingMode = scalingMode;
    switch (scalingMode) {
        case ZFPlayerScalingModeNone:
            self.player.scalingMode = RedScalingModeNone;
            break;
        case ZFPlayerScalingModeAspectFit:
            self.player.scalingMode = RedScalingModeAspectFit;
            break;
        case ZFPlayerScalingModeAspectFill:
            self.player.scalingMode = RedScalingModeAspectFill;
            break;
        case ZFPlayerScalingModeFill:
            self.player.scalingMode = RedScalingModeAspectFit;
            break;
            
        default:
            break;
    }
}

- (void)setVolume:(float)volume {
    _volume = MIN(MAX(0, volume), 1);
    self.player.playbackVolume = volume;
}

- (void)setPresentationSize:(CGSize)presentationSize {
    _presentationSize = presentationSize;
    self.view.presentationSize = presentationSize;
    if (self.presentationSizeChanged) {
        self.presentationSizeChanged(self, self.presentationSize);
    }
}

@end
