//
//  NSString+GKCategory.m
//  GKDYVideo
//
//  Created by gaokun on 2021/4/22.
//  Copyright © 2021 QuintGao. All rights reserved.
//

#import "NSString+GKCategory.h"

@implementation NSString (GKCategory)

- (NSString *)gk_unitConvert {
    float value = self.floatValue;
    
    if (value < 0) value = 0;
    
    if (value >= 10000) {
        if (value >= 100000000) {
            return [NSString stringWithFormat:@"%.1f亿",value / 100000000.0f];
        }
        return [NSString stringWithFormat:@"%.1fw",value / 10000.0f];
    }
    
    return [self isEqualToString:@""] ? @"0" : self;
}

@end
