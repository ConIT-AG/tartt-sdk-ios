//
//  TARTTChannelManager.h
//  Pods
//
//
//

#import <Foundation/Foundation.h>
#import "TARTTChannel.h"
#import "TARTTConfig.h"

/// this is used for the folder structure in the cache dir of the device
#define kCHANNELBASEDIR @"TARTT/Channels"

/*!
 @class TARTTChannelManager
 
 @abstract the static channel manager prepares the channel.
 It provides all needed paths and makes sure they are available in the system.
 */

@interface TARTTChannelManager : NSObject

/*!
 @abstract creates a channel object with needed paths and makes sure they exists
 @param config the configuration object from parse
 @param error an error pointer that might be set if anything cant be created
 */
-(TARTTChannel *)prepareChannelWithConfig:(TARTTConfig *)config error:(NSError **)error;

/*!
 @abstract cleans up the directories of the channel. Removes old directories and the temp folder
 @param channel the channel that should be cleaned
 @param error the pointer of error if something goes wrong
 */
-(BOOL)cleanUpChannel:(TARTTChannel *)channel error:(NSError **)error;
/*!
 @abstract deletes a channel and every directory that it used
 @param channel the channel that should be cleaned
 @param error the pointer of error if something goes wrong
 */

-(BOOL)deleteChannel:(TARTTChannel *)channel error:(NSError **)error;
/*!
 @abstract saves the current path in user defaults so we remember where the folder is next time we try to download
 @param lastPath path that should be saved
 @param channelKey the identiefier of the channel
 */
-(void)saveLastPath:(NSString *)lastPath forChannel:(NSString *)channelKey;

/*!
 @abstract singelton pattern here because every operation is on a static basis
 */
+(TARTTChannelManager *)defaultManager;
@end
