//
//  RedPreLoad.h
//  RedPlayer
//
//  Created by zijie on 2023/12/19.
//  Copyright © 2023 Xiaohongshu. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// Enum for RedPreLoadControllerMsgType
typedef NS_ENUM(NSUInteger, RedPreLoadControllerMsgType) {
  /// No message type
  RedPreLoadControllerMsgTypeNone,
  /// Message type for completed
  RedPreLoadControllerMsgTypeCompleted,
  /// Message type for error
  RedPreLoadControllerMsgTypeError,
  /// Message type for cached
  RedPreLoadControllerMsgTypeCached,
  /// Message type for speed
  RedPreLoadControllerMsgTypeSpeed,
  /// Message type for DNS will parse
  RedPreLoadControllerMsgTypeDnsWillParse,
  /// Message type for DNS did parse
  RedPreLoadControllerMsgTypeDnsDidParse,
  /// Message type for release
  RedPreLoadControllerMsgTypeRelease
};

/// Struct for RedPreLoadTask
typedef struct {
  int error;               ///< Error code
  NSString *_Nullable url; ///< URL for the task
  int64_t trafficBytes;    ///< Traffic bytes for the task
  int64_t tcpSpeed;        ///< TCP speed for the task
  NSString *host;          ///< Host for the task
  NSString *cacheFilePath; ///< Cache file path for the task
  int64_t cacheSize;       ///< Cache size for the task
} RedPreLoadTask;

/// Struct for RedPreloadParam
typedef struct {
  NSString *cachePath;            ///< Cache path
  int64_t preloadSize;            ///< Preload size
  NSString *referer;              ///< Referer
  int dnsTimeout;                 ///< DNS timeout
  bool useHttps;                  ///< Use HTTPS or not
  NSString *userAgent;            ///< User agent
  NSString *header;               ///< Header
  int64_t cache_max_dir_capacity; ///< Maximum directory capacity for cache
  uint32_t cache_max_entries;     ///< Maximum entries for cache
} RedPreloadParam;

/// Callback for RedPreLoad
typedef void (^RedPreLoadCallback)(const RedPreLoadTask task,
                                   RedPreLoadControllerMsgType msgType,
                                   void *userData);

@interface RedPreLoad : NSObject

/// Open JSON with parameters and user data
- (void)openJson:(NSString *)jsonStr
           param:(RedPreloadParam)param
        userData:(void *_Nullable)userData;

/// Open URL with parameters and user data
- (void)open:(NSURL *)url
       param:(RedPreloadParam)param
    userData:(void *_Nullable)userData;

/// Close URL
- (void)close;

/// Set preload message callback
+ (void)setPreLoadMsgCallback:(RedPreLoadCallback)callback;

/// Initialize preload with cache path and maximum size
+ (void)initPreLoad:(NSString *)cachePath maxSize:(uint32_t)maxSize;

/// Initialize preload with cache path, maximum size, and maximum directory
/// capacity
+ (void)initPreLoad:(NSString *)cachePath
            maxSize:(uint32_t)maxSize
     maxdircapacity:(int64_t)maxdircapacity;

/// Stop preload
+ (void)stop;

/// Get cached size
+ (int64_t)getCachedSize:(NSString *)path
                     uri:(NSString *)uri
               isFullUrl:(BOOL)isFullUrl;

/// Get all cached files
+ (NSArray<NSString *> *)getAllCachedFile:(NSString *)path;

/// Delete cache
+ (int)deleteCache:(NSString *)path
               uri:(NSString *)uri
         isFullUrl:(BOOL)isFullUrl;

@end
NS_ASSUME_NONNULL_END
