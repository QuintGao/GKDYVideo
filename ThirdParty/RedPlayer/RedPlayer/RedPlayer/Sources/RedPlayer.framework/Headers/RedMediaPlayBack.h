//
//  RedMediaPlayback.h
//  RedPlayer
//
//  Created by zijie on 2023/12/19.
//  Copyright © 2023 Xiaohongshu. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
/// Enum for RedScalingMode
typedef NS_ENUM(NSInteger, RedScalingMode) {
  RedScalingModeNone,       ///< No scaling
  RedScalingModeAspectFit,  ///< Uniform scale until one dimension fits
  RedScalingModeAspectFill, ///< Uniform scale until the movie fills the visible
                            ///< bounds. One dimension may have clipped contents
  RedScalingModeFill ///< Non-uniform scale. Both render dimensions will exactly
                     ///< match the visible bounds
};

/// Enum for RedPlaybackState
typedef NS_ENUM(NSInteger, RedPlaybackState) {
  RedPlaybackStateStopped,        ///< Playback is stopped
  RedPlaybackStatePlaying,        ///< Playback is playing
  RedPlaybackStatePaused,         ///< Playback is paused
  RedPlaybackStateInterrupted,    ///< Playback is interrupted
  RedPlaybackStateSeekingForward, ///< Playback is seeking forward
  RedPlaybackStateSeekingBackward ///< Playback is seeking backward
};

/// Enum for RedLoadState
typedef NS_OPTIONS(NSUInteger, RedLoadState) {
  RedLoadStateUnknown = 0,       ///< Unknown load state
  RedLoadStatePlayable = 1 << 0, ///< State when playable
  RedLoadStatePlaythroughOK =
      1 << 1, ///< Playback will be automatically started in this state when
              ///< shouldAutoplay is YES
  RedLoadStateStalled = 1 << 2, ///< Playback will be automatically paused in
                                ///< this state, if started
};

/// Enum for RedFinishReason
typedef NS_ENUM(NSInteger, RedFinishReason) {
  RedFinishReasonPlaybackEnded, ///< Playback ended
  RedFinishReasonPlaybackError, ///< Playback error
  RedFinishReasonUserExited     ///< User exited
};

/// Enum for RedVideoFirstRenderingReason
typedef NS_ENUM(NSInteger, RedVideoFirstRenderingReason) {
  RedVideoFirstRenderingReasonStart,    ///< Start rendering
  RedVideoFirstRenderingReasonWaitStart ///< Wait start rendering
};

/// Enum for RedRenderType
typedef NS_ENUM(NSUInteger, RedRenderType) {
  RedRenderTypeOpenGL,                   ///< OpenGL render type
  RedRenderTypeMetal,                    ///< Metal render type
  RedRenderTypeSampleBufferDisplayLayer, ///< Sample buffer display layer render
                                         ///< type
};

#pragma mark RedMediaPlayback

@protocol RedMediaPlayback <NSObject>

/// The view associated with the playback.
@property(nonatomic, readonly) UIView *view;
/// The current playback time.
@property(nonatomic) NSTimeInterval currentPlaybackTime;
/// The total duration of the media.
@property(nonatomic, readonly) NSTimeInterval duration;
/// The duration of media that can be played without buffering.
@property(nonatomic, readonly) NSTimeInterval playableDuration;
/// The buffering progress as a percentage.
@property(nonatomic, readonly) NSInteger bufferingProgress;

/// Indicates whether the playback is prepared to play.
@property(nonatomic, readonly) BOOL isPreparedToPlay;
/// The current playback state.
@property(nonatomic, readonly) RedPlaybackState playbackState;
/// The current load state.
@property(nonatomic, readonly) RedLoadState loadState;
/// Indicates whether seeking is in progress.
@property(nonatomic, readonly) int isSeekBuffering;
/// Indicates audio synchronization status.
@property(nonatomic, readonly) int isAudioSync;
/// Indicates video synchronization status.
@property(nonatomic, readonly) int isVideoSync;

/// The real cached bytes for video.
@property(nonatomic, readonly) int64_t videoRealCachedBytes;
/// The total file size of the video.
@property(nonatomic, readonly) int64_t videoFileSize;
/// The maximum buffer size.
@property(nonatomic, readonly) int64_t maxBufferSize;
/// The current buffer size for video.
@property(nonatomic, readonly) int64_t videoBufferBytes;
/// The current buffer size for audio.
@property(nonatomic, readonly) int64_t audioBufferBytes;

/// Video decode per second.
@property(nonatomic, readonly) float vdps;
/// Video render frames per second.
@property(nonatomic, readonly) float vRenderFps;

/// The duration of cached content.
@property(nonatomic, readonly) int64_t cachedDuration;

/// The natural size of the media.
@property(nonatomic, readonly) CGSize naturalSize;
/// The scaling mode for video playback.
@property(nonatomic) RedScalingMode scalingMode;
/// Indicates whether autoplay is enabled.
@property(nonatomic) BOOL shouldAutoplay;

/// The playback rate.
@property(nonatomic) float playbackRate;
/// The playback volume.
@property(nonatomic) float playbackVolume;

/// Indicates whether soft decoding is enabled.
@property(nonatomic, readonly) BOOL isSoftDecoding;

/// Indicates whether to pause the GLView background.
@property(nonatomic) BOOL notPauseGlviewBackground;

/// Frames per second in metadata.
@property(nonatomic, readonly) CGFloat fpsInMeta;

/// Sets the content URL for playback.
- (void)setContentURL:(NSURL *)URL;

/// Sets the content string for playback.
- (void)setContentString:(NSString *)aString;

/// Sets the content URL list for playback.
- (void)setContentURLList:(NSString *)aString;

/// Prepares the media for playback.
- (void)prepareToPlay;

/// Starts playback.
- (void)play;

/// Pauses playback.
- (void)pause;

/// Returns whether the media is currently playing.
- (BOOL)isPlaying;

/// Shuts down the media playback.
- (void)shutdown;

/// Sets whether to pause in the background.
- (void)setPauseInBackground:(BOOL)pause;

/// Retrieves the current playback URL.
- (NSString *)getPlayUrl;

/// Seeks to the specified playback time.
- (BOOL)seekCurrentPlaybackTime:(NSTimeInterval)aCurrentPlaybackTime;

/// Returns the rate of dropped packets before decoding.
- (float)dropPacketRateBeforeDecode;

/// Returns the rate of dropped frames.
- (float)dropFrameRate;

/// Returns the loop setting.
- (int)getLoop;

/// Sets the loop setting.
- (void)setLoop:(int)loop;

/// Returns whether the audio is muted.
- (BOOL)getMute;

/// Sets the mute status.
- (void)setMute:(BOOL)muted;

/// Sets the video cache directory.
- (void)setVideoCacheDir:(NSString *)dir;

/// Sets whether HDR is enabled.
- (void)setEnableHDR:(BOOL)enable;

/// Sets whether Video Toolbox is enabled.
- (void)setEnableVTB:(BOOL)enable;

/// Sets whether video is live source.
- (void)setLiveMode:(BOOL)enable;

/// Returns whether Video Toolbox is open.
- (BOOL)isVideoToolboxOpen;

/// Retrieves debug information for video.
- (NSDictionary *)getVideoDebugInfo;

#pragma mark - Notifications

#ifdef __cplusplus
#define RED_EXTERN extern "C" __attribute__((visibility("default")))
#else
#define RED_EXTERN extern __attribute__((visibility("default")))
#endif

// -----------------------------------------------------------------------------
//  MPMediaPlayback.h

/// Notification posted when the prepared state changes for an object conforming
/// to MPMediaPlayback protocol.
RED_EXTERN NSString
    *const RedMediaPlaybackIsPreparedToPlayDidChangeNotification;

// -----------------------------------------------------------------------------
//  MPMoviePlayerController.h
//  Movie Player Notifications

/// Notification posted when the scaling mode changes.
RED_EXTERN NSString *const RedPlayerScalingModeDidChangeNotification;

/// Notification posted when movie playback ends or a user exits playback.
RED_EXTERN NSString *const RedPlayerPlaybackDidFinishNotification;
RED_EXTERN NSString *const
    RedPlayerPlaybackDidFinishReasonUserInfoKey; // NSNumber
                                                 // (REDMPMovieFinishReason)
RED_EXTERN NSString
    *const RedPlayerPlaybackDidFinishErrorUserInfoKey; // NSNumber (errorCode)
RED_EXTERN NSString *const
    RedPlayerPlaybackDidFinishDetailedErrorUserInfoKey; // NSNumber (errorCode),
                                                        // more detailed error
                                                        // code

/// Notification posted when the playback state changes, either programmatically
/// or by the user.
RED_EXTERN NSString *const RedPlayerPlaybackStateDidChangeNotification;

/// Notification posted when the network load state changes.
RED_EXTERN NSString *const RedPlayerLoadStateDidChangeNotification;

// -----------------------------------------------------------------------------
// Movie Property Notifications

/// Notification posted when natural size is available after calling
/// -prepareToPlay.
RED_EXTERN NSString *const RedPlayerNaturalSizeAvailableNotification;

// -----------------------------------------------------------------------------
//  Extend Notifications

RED_EXTERN NSString *const RedPlayerVideoDecoderOpenNotification;
RED_EXTERN NSString *const RedPlayerFirstVideoFrameRenderedNotification;
RED_EXTERN NSString *const RedPlayerFirstVideoFrameRenderedNotificationUserInfo;
RED_EXTERN NSString *const RedPlayerFirstAudioFrameRenderedNotification;
RED_EXTERN NSString *const RedPlayerFirstAudioFrameDecodedNotification;
RED_EXTERN NSString *const RedPlayerFirstVideoFrameDecodedNotification;
RED_EXTERN NSString *const RedPlayerOpenInputNotification;
RED_EXTERN NSString *const RedPlayerFindStreamInfoNotification;
RED_EXTERN NSString *const RedPlayerComponentOpenNotification;

RED_EXTERN NSString *const RedPlayerDidSeekCompleteNotification;
RED_EXTERN NSString *const RedPlayerDidSeekCompleteTargetKey;
RED_EXTERN NSString *const RedPlayerDidSeekCompleteErrorKey;
RED_EXTERN NSString *const RedPlayerDidAccurateSeekCompleteCurPos;
RED_EXTERN NSString *const RedPlayerAccurateSeekCompleteNotification;
RED_EXTERN NSString *const RedPlayerSeekAudioStartNotification;
RED_EXTERN NSString *const RedPlayerSeekVideoStartNotification;

RED_EXTERN NSString *const RedPlayerVideoFirstPacketInDecoderNotification;
RED_EXTERN NSString *const RedPlayerVideoStartOnPlayingNotification;

RED_EXTERN NSString *const RedPlayerCacheDidFinishNotification;
RED_EXTERN NSString *const RedPlayerCacheURLUserInfoKey; // NSURL

// Network
RED_EXTERN NSString *const RedPlayerUrlChangeMsgNotification;

RED_EXTERN NSString *const RedPlayerUrlChangeCurUrlKey;
RED_EXTERN NSString *const RedPlayerUrlChangeCurUrlHttpCodeKey;
RED_EXTERN NSString *const RedPlayerUrlChangeNextUrlKey;

RED_EXTERN NSString *const RedPlayerMessageTimeUserInfoKey;

@end
