//
//  TARTTChannelManager.h
//  Pods
//
//  Created by Thomas Opiolka on 07.10.15.
//
//

#import <Foundation/Foundation.h>
#import "TARTTChannel.h"
#import "TARTTConfig.h"

#define kCHANNELBASEDIR @"TARTT/Channels"

@interface TARTTChannelManager : NSObject

-(instancetype)initWithConfig:(TARTTConfig*) config;

-(TARTTChannel *)getChannelInstance;
-(BOOL)cleanUpChannel:(TARTTChannel *)channel;
-(BOOL)deleteChannel:(TARTTChannel *)channel;
@end
