//
//  GKDYTools.m
//  GKDYVideo
//
//  Created by QuintGao on 2023/3/20.
//  Copyright © 2023 QuintGao. All rights reserved.
//

#import "GKDYTools.h"

@implementation GKDYTools

+ (NSString *)convertTimeSecond:(NSInteger)timeSecond {
    NSString *theLastTime = nil;
    long second = timeSecond;
    if (timeSecond < 60) {
        theLastTime = [NSString stringWithFormat:@"00:%02zd", second];
    }else if (timeSecond >= 60 && timeSecond < 3600) {
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd", second/60, second%60];
    }else if (timeSecond >= 3600) {
        theLastTime = [NSString stringWithFormat:@"%02zd:%02zd:%02zd", second/3600, second%3600/60, second%60];
    }
    return theLastTime;
}

@end
