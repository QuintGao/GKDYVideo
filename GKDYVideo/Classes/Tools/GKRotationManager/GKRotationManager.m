//
//  GKRotationManager.m
//  Example
//
//  Created by QuintGao on 2023/3/31.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKRotationManager.h"
#import "GKLandscapeWindow.h"
#import "GKLandscapeViewController.h"
#import "GKRotationManager_iOS_9_15.h"
#import "GKRotationManager_iOS_16_Later.h"
#import <objc/message.h>

@interface GKRotationManager()<GKLandscapeViewControllerDelegate>

@property (nonatomic, assign) BOOL isGeneratingDeviceOrientation;

@end

@implementation GKRotationManager

+ (GKInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(UIWindow *)window {
    if ([window isKindOfClass:GKLandscapeWindow.class]) {
        GKRotationManager *manager = [(GKLandscapeWindow *)window rotationManager];
        if (manager != nil) {
            return (GKInterfaceOrientationMask)[manager supportedInterfaceOrientationsForWindow:window];
        }
    }
    return GKInterfaceOrientationMaskUnknow;
}

+ (instancetype)rotationManager {
    if (@available(iOS 16.0, *)) {
        return [[GKRotationManager_iOS_16_Later alloc] _init];
    }else {
        return [[GKRotationManager_iOS_9_15 alloc] _init];
    }
}

- (instancetype)_init {
    if (self = [super init]) {
        self.currentOrientation = UIInterfaceOrientationPortrait;
        self.supportInterfaceOrientation = GKInterfaceOrientationMaskAll;
    }
    return self;
}

- (void)addDeviceOrientationObserver {
    self.isGeneratingDeviceOrientation = UIDevice.currentDevice.isGeneratingDeviceOrientationNotifications;
    if (!self.isGeneratingDeviceOrientation) {
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(handleDeviceOrientationChange) name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)removeDeviceOrientationObserver {
    if (!self.isGeneratingDeviceOrientation) {
        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    }
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)dealloc {
#ifdef DEBUG
    NSLog(@"%d -- [%@ %s]", (int)__LINE__, NSStringFromClass(self.class), sel_getName(_cmd));
#endif
    [_window setHidden:YES];
    [self removeDeviceOrientationObserver];
}

- (void)setAllowOrientationRotation:(BOOL)allowOrientationRotation {
    _allowOrientationRotation = allowOrientationRotation;
    
    if (allowOrientationRotation) {
        [self addDeviceOrientationObserver];
    }else {
        [self removeDeviceOrientationObserver];
    }
}

- (UIInterfaceOrientation)currentDeviceOrientation {
    return (UIInterfaceOrientation)UIDevice.currentDevice.orientation;
}

- (void)rotate {
    UIInterfaceOrientation orientation = self.currentOrientation == UIInterfaceOrientationPortrait ? UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait;
    [self rotateToOrientation:orientation animated:YES];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated {
    [self rotateToOrientation:orientation animated:animated completion:nil];
}

- (void)rotateToOrientation:(UIInterfaceOrientation)orientation animated:(BOOL)animated completion:(void (^)(void))completion {
    self.currentOrientation = orientation;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (!self.window) {
            self.window = [[GKLandscapeWindow alloc] init];
            self.window.rootViewController = self.landscapeViewController;
            self.window.rotationManager = self;
        }
    }
    self.disableAnimations = !animated;
    if (UIDevice.currentDevice.systemVersion.doubleValue < 16.0) {
        [self interfaceOrientation:UIInterfaceOrientationUnknown completion:nil];
    }
    [self interfaceOrientation:orientation completion:completion];
}
 
@end

@implementation GKRotationManager (Internal)

@dynamic disableAnimations;

- (void)setDisableAnimations:(BOOL)disableAnimations {
    objc_setAssociatedObject(self, @selector(disableAnimations), @(disableAnimations), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)disableAnimations {
    return [objc_getAssociatedObject(self, _cmd) boolValue];
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientationsForWindow:(nullable UIWindow *)window {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (UIInterfaceOrientation)getCurrentOrientation {
    if (@available(iOS 16.0, *)) {
        NSArray *array = UIApplication.sharedApplication.connectedScenes.allObjects;
        UIWindowScene *scene = array.firstObject;
        return scene.interfaceOrientation;
    }else {
        return self.currentDeviceOrientation;
    }
}

- (GKLandscapeViewController *)landscapeViewController {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"You must override %@ in a subclass.", NSStringFromSelector(_cmd)]
                                 userInfo:nil];
}

- (void)interfaceOrientation:(UIInterfaceOrientation)orientation completion:(void (^)(void))completion {
    // subclass implementation
}

- (void)handleDeviceOrientationChange {
    if (!self.allowOrientationRotation) return;
    if (!UIDeviceOrientationIsValidInterfaceOrientation([UIDevice currentDevice].orientation)) return;
    UIInterfaceOrientation currentOrientation = self.currentDeviceOrientation;
    if (currentOrientation == self.currentOrientation) return;
    self.currentOrientation = currentOrientation;
    if (currentOrientation == UIInterfaceOrientationPortraitUpsideDown) return;
    
    switch (currentOrientation) {
        case UIInterfaceOrientationPortrait: {
            if ([self _isSupportedPortrait]) {
                [self rotateToOrientation:UIInterfaceOrientationPortrait animated:YES];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeLeft: {
            if ([self _isSupportedLandscapeLeft]) {
                [self rotateToOrientation:UIInterfaceOrientationLandscapeLeft animated:YES];
            }
        }
            break;
        case UIInterfaceOrientationLandscapeRight: {
            if ([self _isSupportedLandscapeRight]) {
                [self rotateToOrientation:UIInterfaceOrientationLandscapeRight animated:YES];
            }
        }
            break;
        default: break;
    }
}

- (BOOL)isSupportInterfaceOrientation:(UIInterfaceOrientation)orientation {
    if (orientation == UIInterfaceOrientationPortrait) {
        return [self _isSupportedPortrait];
    }else if (orientation == UIInterfaceOrientationLandscapeLeft) {
        return [self _isSupportedLandscapeLeft];
    }else if (orientation == UIInterfaceOrientationLandscapeRight) {
        return [self _isSupportedLandscapeRight];
    }else if (orientation == UIInterfaceOrientationPortraitUpsideDown) {
        return [self _isSupportedPortraitUpsideDown];
    }
    return NO;
}

- (void)willChangeOrientation:(UIInterfaceOrientation)orientation {
    _isFullscreen = UIInterfaceOrientationIsLandscape(orientation);
    !self.orientationWillChange ?: self.orientationWillChange(_isFullscreen);
}

- (void)didChangeOrientation:(UIInterfaceOrientation)orientation {
    _isFullscreen = UIInterfaceOrientationIsLandscape(orientation);
    !self.orientationDidChanged ?: self.orientationDidChanged(_isFullscreen);
}

- (BOOL)_isSupportedPortrait {
    return self.supportInterfaceOrientation & GKInterfaceOrientationMaskPortrait;
}

- (BOOL)_isSupportedPortraitUpsideDown {
    return self.supportInterfaceOrientation & GKInterfaceOrientationMaskPortraitUpsideDown;
}

- (BOOL)_isSupportedLandscapeLeft {
    return self.supportInterfaceOrientation & GKInterfaceOrientationMaskLandscapeLeft;
}

- (BOOL)_isSupportedLandscapeRight {
    return self.supportInterfaceOrientation & GKInterfaceOrientationMaskLandscapeRight;
}

@end

#pragma mark - fix safe area

API_DEPRECATED("deprecated!", ios(13.0, 16.0)) @implementation GKRotationManager (GKRotationSafeAreaFixing)
+ (void)initialize {
    if (@available(iOS 16.0, *)) return;
    if (@available(iOS 13.0, *)) {
        static dispatch_once_t onceToken;
        dispatch_once(&onceToken, ^{
            Class cls = UIViewController.class;
            NSData *data = [NSData.alloc initWithBase64EncodedString:@"X3NldENvbnRlbnRPdmVybGF5SW5zZXRzOmFuZExlZnRNYXJnaW46cmlnaHRNYXJnaW46" options:kNilOptions];
            NSString *method = [NSString.alloc initWithData:data encoding:NSUTF8StringEncoding];
            SEL originalSelector = NSSelectorFromString(method);
            SEL swizzledSelector = NSSelectorFromString([@"gk_" stringByAppendingString:method]);
            
            Method originalMethod = class_getInstanceMethod(cls, originalSelector);
            Method swizzledMethod = class_getInstanceMethod(cls, swizzledSelector);
            if ( originalMethod != NULL ) method_exchangeImplementations(originalMethod, swizzledMethod);
        });
    }
}
@end

API_DEPRECATED("deprecated!", ios(13.0, 16.0)) @implementation UIViewController (GKRotationSafeAreaFixing)
- (void)gk_setContentOverlayInsets:(UIEdgeInsets)insets andLeftMargin:(CGFloat)leftMargin rightMargin:(CGFloat)rightMargin {
    GKSafeAreaInsetsMask mask = self.disabledAdjustSafeAreaInsetsMask;
    if (mask & GKSafeAreaInsetsMaskTop) insets.top = 0;
    if (mask & GKSafeAreaInsetsMaskLeft) insets.left = 0;
    if (mask & GKSafeAreaInsetsMaskBottom) insets.bottom = 0;
    if (mask & GKSafeAreaInsetsMaskRight) insets.right = 0;
    
    UIWindow *keyWindow = UIApplication.sharedApplication.keyWindow;
    UIWindow *otherWindow = self.view.window;
    if ([keyWindow isKindOfClass:GKLandscapeWindow.class] && otherWindow != nil) {
        GKRotationManager *manager = ((GKLandscapeWindow *)keyWindow).rotationManager;
        UIWindow *superviewWindow = manager.containerView.window;
        if (superviewWindow != otherWindow) {
            [self gk_setContentOverlayInsets:insets andLeftMargin:leftMargin rightMargin:rightMargin];
        }
    }else {
        [self gk_setContentOverlayInsets:insets andLeftMargin:leftMargin rightMargin:rightMargin];
    }
}

- (void)setDisabledAdjustSafeAreaInsetsMask:(GKSafeAreaInsetsMask)disabledAdjustSafeAreaInsetsMask {
    objc_setAssociatedObject(self, @selector(disabledAdjustSafeAreaInsetsMask), @(disabledAdjustSafeAreaInsetsMask), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (GKSafeAreaInsetsMask)disabledAdjustSafeAreaInsetsMask {
    return [objc_getAssociatedObject(self, _cmd) integerValue];
}

@end
