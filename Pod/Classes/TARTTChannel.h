//
//  TARTTChannel.h
//  Pods
//
//  Created by Thomas Opiolka on 06.10.15.
//
//

#import <Foundation/Foundation.h>

@interface TARTTChannel : NSObject

@property (nonatomic, strong) NSString *mainPath;
@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, strong) NSString *lastPath;
@property (nonatomic, strong) NSString *tempPath;
@property (nonatomic, strong) NSDictionary *config;

@end
