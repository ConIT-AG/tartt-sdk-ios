//
//  WikitudeManager.m
//  TARTT
//
//  Created by Thomas on 19.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import "WikitudeManager.h"

@implementation WikitudeManager

+ (WTArchitectView *)architectView
{
    static WTArchitectView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[WTArchitectView alloc] init];
    });
    return sharedInstance;
}

@end
