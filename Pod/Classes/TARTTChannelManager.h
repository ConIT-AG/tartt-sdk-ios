//
//  TARTTChannelManager.h
//  Pods
//
//
//

#import <Foundation/Foundation.h>
#import "TARTTChannel.h"
#import "TARTTConfig.h"

#define kCHANNELBASEDIR @"TARTT/Channels"

@interface TARTTChannelManager : NSObject

-(TARTTChannel *)prepareChannelWithConfig:(TARTTConfig *)config error:(NSError **)error;
-(BOOL)cleanUpChannel:(TARTTChannel *)channel error:(NSError **)error;
-(BOOL)deleteChannel:(TARTTChannel *)channel error:(NSError **)error;

-(void)saveLastPath:(NSString *)lastPath forChannel:(NSString *)channelKey;

+(TARTTChannelManager *)defaultManager;
@end
