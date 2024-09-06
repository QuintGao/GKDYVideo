//
//  RedPlayerController.h
//  RedPlayer
//
//  Created by zijie on 2023/12/19.
//  Copyright © 2023 Xiaohongshu. All rights reserved.
//

#import <RedPlayer/RedMediaPlayBack.h>
#import <UIKit/UIKit.h>
/// Enumeration for RedLogLevel
typedef enum RedLogLevel {
  k_RED_LOG_UNKNOWN = 0,
  k_RED_LOG_DEFAULT = 1,

  k_RED_LOG_VERBOSE = 2,
  k_RED_LOG_DEBUG = 3,
  k_RED_LOG_INFO = 4,
  k_RED_LOG_WARN = 5,
  k_RED_LOG_ERROR = 6,
  k_RED_LOG_FATAL = 7,
  k_RED_LOG_SILENT = 8,
} RedLogLevel;

/// Enumeration for REDLogCallScene
typedef NS_ENUM(NSInteger, REDLogCallScene) {
  REDLogCallScene_Undefine, ///< Undefine
  REDLogCallScene_Default,  ///< Default
  REDLogCallScene_Video,    ///< Video
  REDLogCallScene_Live      ///< Live
};

/// Callback block for RedLogCallback
typedef void (^RedLogCallback)(RedLogLevel logLevel, NSString *tagInfo,
                               NSString *logContent);

@interface RedPlayerController : NSObject <RedMediaPlayback>

/**
 Initializes RedPlayerController with a content URL and render type.

 @param aUrl The content URL.
 @param renderType The render type.
 @return An instance of RedPlayerController.
 */
- (id)initWithContentURL:(NSURL *)aUrl withRenderType:(RedRenderType)renderType;

/**
 Initializes RedPlayerController with a content URL string and render type.

 @param aUrlString The content URL string.
 @param renderType The render type.
 @return An instance of RedPlayerController.
 */
- (id)initWithContentURLString:(NSString *)aUrlString
                withRenderType:(RedRenderType)renderType;

/**
 Sets the log callback level for the RedPlayerController.

 @param logLevel The log level for the log callback.
 */
+ (void)setLogCallbackLevel:(RedLogLevel)logLevel;

/**
 Sets the log callback for the RedPlayerController.

 @param logCallback The log callback block.
 */
+ (void)setLogCallback:(RedLogCallback)logCallback;

/**
 Sets the log callback for the RedPlayerController with a specific log call
 scene.

 @param logCallback The log callback block.
 @param logCallScene The log call scene.
 */
+ (void)setLogCallback:(RedLogCallback)logCallback
          logCallScene:(REDLogCallScene)logCallScene;

@end
