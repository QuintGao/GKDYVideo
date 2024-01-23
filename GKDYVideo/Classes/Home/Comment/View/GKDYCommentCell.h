//
//  GKDYCommentCell.h
//  GKDYVideo
//
//  Created by QuintGao on 2024/1/18.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GKDYCommentModel.h"

NS_ASSUME_NONNULL_BEGIN

@interface GKDYCommentCell : UITableViewCell

- (void)loadData:(GKDYCommentInfoModel *)model;

+ (CGFloat)heightWithModel:(GKDYCommentInfoModel *)model;

@end

NS_ASSUME_NONNULL_END
