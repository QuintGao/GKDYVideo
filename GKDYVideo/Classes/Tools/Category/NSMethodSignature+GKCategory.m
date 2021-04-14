//
//  NSMethodSignature+GKCategory.m
//  GKDYVideo
//
//  Created by QuintGao on 2019/10/24.
//  Copyright © 2019 GKDYVideo. All rights reserved.
//

#import "NSMethodSignature+GKCategory.h"

#define AYArgumentToString(macro) #macro
#define AYClangWarningConcat(warning_name) AYArgumentToString(clang diagnostic ignored warning_name)

/// 参数可直接传入 clang 的 warning 名，warning 列表参考：https://clang.llvm.org/docs/DiagnosticsReference.html
#define AYBeginIgnoreClangWarning(warningName) _Pragma("clang diagnostic push") _Pragma(AYClangWarningConcat(#warningName))
#define AYEndIgnoreClangWarning _Pragma("clang diagnostic pop")

#define AYBeginIgnorePerformSelectorLeaksWarning AYBeginIgnoreClangWarning(-Warc-performSelector-leaks)
#define AYEndIgnorePerformSelectorLeaksWarning AYEndIgnoreClangWarning

#define AYBeginIgnoreAvailabilityWarning AYBeginIgnoreClangWarning(-Wpartial-availability)
#define AYEndIgnoreAvailabilityWarning AYEndIgnoreClangWarning

#define AYBeginIgnoreDeprecatedWarning AYBeginIgnoreClangWarning(-Wdeprecated-declarations)
#define AYEndIgnoreDeprecatedWarning AYEndIgnoreClangWarning

@implementation NSMethodSignature (GKCategory)

- (NSString *)ay_typeString {
    AYBeginIgnorePerformSelectorLeaksWarning
    NSString *typeString = [self performSelector:NSSelectorFromString([NSString stringWithFormat:@"_%@String", @"type"])];
    AYEndIgnorePerformSelectorLeaksWarning
    return typeString;
}

- (const char *)ay_typeEncoding {
    return self.ay_typeString.UTF8String;
}

@end
