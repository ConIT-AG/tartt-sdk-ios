//
//  TARTTChannelConfigManager.h
//  Pods
//
//
//

#import <Foundation/Foundation.h>
#import "TARTTChannel.h"
#import "TARTTConfig.h"
#import "TARTTErrors.h"
#import "TARTTRequestOptions.h"

@protocol TARTTChannelConfigRequestDelegate <NSObject>

-(void)finishedConfigRequestWithError:(NSError *)error;
-(void)finishedConfigRequestWithMultipleChannels;
-(void)finishedConfigRequestWithSuccess:(TARTTConfig *)config;
@end


@interface TARTTChannelConfigRequest : NSObject

-(instancetype)initWithApplicationID:(NSString*)applicationID andClientKey:(NSString *)clientKey andOptions:(TARTTRequestOptions *)options;

-(void)startRequestWithDelegate:(id<TARTTChannelConfigRequestDelegate>)delegate;
-(void)selectChannel:(NSString *)channelKey andDelegate:(id<TARTTChannelConfigRequestDelegate>)delegate;
-(void)cancel;

@end