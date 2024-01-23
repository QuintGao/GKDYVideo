//
//  GKPopupController.h
//  GKPopupController
//
//  Created by QuintGao on 2024/1/12.
//

#import <UIKit/UIKit.h>
#import "GKPopupProtocol.h"

NS_ASSUME_NONNULL_BEGIN

typedef NS_ENUM(NSUInteger, GKPopupShowType) {
    GKPopupShowTypeShort,
    GKPopupShowTypeLong
};

@interface GKPopupController : UIViewController

@property (nonatomic, weak) id<GKPopupProtocol> delegate;

@property (nonatomic, assign) GKPopupShowType showType;

- (void)show;

- (void)dismiss;

- (void)refreshContentHeight;

@end

NS_ASSUME_NONNULL_END
