//
//  TARTTChannel.h
//  Pods
//
//
//

#import <Foundation/Foundation.h>
#import "TARTTConfig.h"

@interface TARTTChannel : NSObject

@property (nonatomic, strong) NSString *mainPath;
@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, strong) NSString *lastPath;
@property (nonatomic, strong) NSString *tempPath;
@property (nonatomic, strong) TARTTConfig *config;

@end
