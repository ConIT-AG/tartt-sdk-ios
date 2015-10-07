//
//  TARTTChannelManager.h
//  Pods
//
//  Created by Thomas Opiolka on 07.10.15.
//
//

#import <Foundation/Foundation.h>
#import "TARTTChannel.h"

#define kCHANNELKEY @"TTARTChannelCurrentVersion"

@protocol TARTTChannelManagerDelegate <NSObject>

-(void)finishedInitWithError:(NSError *)error;
-(void)finishedWithMultipleChannels;
-(void)finishedWithChannel:(TARTTChannel *)channel;

@end

@interface TARTTChannelManager : NSObject

-(void)requestChannelSetupWithDelegate:(id<TARTTChannelManagerDelegate>)delegate;

-(TARTTChannel *)getChannel:(NSString *)channelKey;
@end
