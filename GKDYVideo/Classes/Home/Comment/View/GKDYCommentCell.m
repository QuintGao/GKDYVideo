//
//  GKDYCommentCell.m
//  GKDYVideo
//
//  Created by QuintGao on 2024/1/18.
//  Copyright © 2024 QuintGao. All rights reserved.
//

#import "GKDYCommentCell.h"

@interface GKDYCommentCell()

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) UILabel *contentLabel;

@end

@implementation GKDYCommentCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self initUI];
    }
    return self;
}

- (void)initUI {
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.backgroundColor = UIColor.clearColor;
    self.contentView.backgroundColor = UIColor.clearColor;
    
    [self.contentView addSubview:self.iconView];
    [self.contentView addSubview:self.nameLabel];
    [self.contentView addSubview:self.contentLabel];
    
    [self.iconView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self).offset(15);
        make.top.equalTo(self).offset(15);
        make.width.height.mas_equalTo(36);
    }];
    
    [self.nameLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self).offset(15);
        make.left.equalTo(self.iconView.mas_right).offset(8);
        make.right.equalTo(self).offset(-15);
    }];
    
    [self.contentLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.nameLabel.mas_bottom).offset(6);
        make.left.right.equalTo(self.nameLabel);
    }];
}

- (void)loadData:(GKDYCommentInfoModel *)model {
    [self.iconView sd_setImageWithURL:[NSURL URLWithString:model.avatar]];
    self.nameLabel.text = model.uname;
    self.contentLabel.text = model.content;
}

+ (CGFloat)heightWithModel:(GKDYCommentInfoModel *)model {
    return 15 + [UIFont systemFontOfSize:14].lineHeight + 6 + [self contentHeightWithText:model.content] + 4;
}

+ (CGFloat)contentHeightWithText:(NSString *)text {
    
    CGFloat maxWidth = UIScreen.mainScreen.bounds.size.width - 15 - 15 - 36 - 8;
    
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:text];
    [str addAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16]} range:NSMakeRange(0, text.length)];
    
    CGSize size = [str boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    
    return size.height;
}

#pragma mark - Lazy
- (UIImageView *)iconView {
    if (!_iconView) {
        _iconView = [[UIImageView alloc] init];
        _iconView.layer.cornerRadius = 18;
        _iconView.layer.masksToBounds = YES;
    }
    return _iconView;
}

- (UILabel *)nameLabel {
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.font = [UIFont systemFontOfSize:14];
        _nameLabel.textColor = UIColor.grayColor;
    }
    return _nameLabel;
}

- (UILabel *)contentLabel {
    if (!_contentLabel) {
        _contentLabel = [[UILabel alloc] init];
        _contentLabel.font = [UIFont systemFontOfSize:16];
        _contentLabel.textColor = UIColor.whiteColor;
        _contentLabel.numberOfLines = 0;
    }
    return _contentLabel;
}

@end
