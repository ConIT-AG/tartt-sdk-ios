//
//  TarttManager.m
//  Pods
//
//  Created by Thomas Opiolka on 05.10.15.
//
//

#import "TarttManager.h"



@interface TarttManager()


@property (nonatomic) BOOL isEnabled;

@end

@implementation TarttManager

+(instancetype)sharedManager{
    static TarttManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[[self class] alloc] init];
    });
    return sharedManager;
}

- (void) startManager {
    NSLog(@"Manager is running");
    _isEnabled = YES;   
    
}

- (void) stopManager {
    NSLog(@"Manager stopped..");
    _isEnabled = NO;
}

@end
