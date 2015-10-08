//
//  TARTTChannelManager.h
//  Pods
//
//  Created by Thomas Opiolka on 07.10.15.
//
//

#import <Foundation/Foundation.h>
#import "TARTTChannel.h"
#import "TARTTChannelConfig.h"

@interface TARTTChannelManager : NSObject

-(instancetype)initWithConfig:(TARTTChannelConfig*) config;
-(instancetype)initWithMultipleConfigs:(NSArray *) configs;

-(TARTTChannel *)getChannelInstance;
-(TARTTChannel *)getChannelByKey:(NSString *)channelKey;
-(BOOL)cleanUpChannel:(TARTTChannel *)channel;
-(BOOL)deleteChannel:(TARTTChannel *)channel;

@end
