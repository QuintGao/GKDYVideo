//
//  NSMethodSignature+GKCategory.h
//  GKDYVideo
//
//  Created by QuintGao on 2019/10/24.
//  Copyright © 2019 GKVideo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NSMethodSignature (GKCategory)

/**
 以 NSString 格式返回当前 NSMethodSignature 的 typeEncoding，例如 v@:
 */
@property(nullable, nonatomic, copy, readonly) NSString *ay_typeString;

/**
 以 const char 格式返回当前 NSMethodSignature 的 typeEncoding，例如 v@:
 */
@property(nullable, nonatomic, readonly) const char *ay_typeEncoding;

@end

NS_ASSUME_NONNULL_END
