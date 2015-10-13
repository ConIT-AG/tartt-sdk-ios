//
//  TARTTConfig.m
//  Pods
//
//  Created by Thomas Opiolka on 13.10.15.
//
//

#import "TARTTConfig.h"
#import <Parse/PFObject+Subclass.h>

@implementation TARTTConfig
@dynamic content;
@dynamic channelKey;

+ (void)load {
    [self registerSubclass];
}
+ (NSString *)parseClassName {
    return @"world";
}
@end
