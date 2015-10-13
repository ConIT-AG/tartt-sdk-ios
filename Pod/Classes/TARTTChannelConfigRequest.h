//
//  TARTTChannelConfigManager.h
//  Pods
//
//  Created by Thomas Opiolka on 08.10.15.
//
//

#import <Foundation/Foundation.h>
#import "TARTTChannel.h"
#import "TARTTConfig.h"

FOUNDATION_EXPORT NSString *const TARTTChannelConfigRequestErrorDomain;
typedef NS_ENUM(NSInteger, TARTTChannelConfigRequestErrorType) {
    TARTTChannelConfigRequestErrorNoChannels
};

FOUNDATION_EXPORT NSString *const TARTTChannelConfigRequestOptionLanguage;
FOUNDATION_EXPORT NSString *const TARTTChannelConfigRequestOptionEnvironment;
FOUNDATION_EXPORT NSString *const TARTTChannelConfigRequestOptionTargetAPI;
FOUNDATION_EXPORT NSString *const TARTTChannelConfigRequestOptionTargetType;
FOUNDATION_EXPORT NSString *const TARTTChannelConfigRequestOptionTargetState;


@protocol TARTTChannelConfigRequestDelegate <NSObject>

-(void)finishedConfigRequestWithError:(NSError *)error;
-(void)finishedConfigRequestWithMultipleChannels;
-(void)finishedConfigRequestWithSuccess:(TARTTConfig *)config;
@end


@interface TARTTChannelConfigRequest : NSObject

@property (nonatomic) NSDictionary *options;

-(instancetype)initWithApplicationID:(NSString*)applicationID andClientKey:(NSString *)clientKey;

-(void)startRequestWithDelegate:(id<TARTTChannelConfigRequestDelegate>)delegate;
-(void)selectChannel:(NSString *)channelKey andDelegate:(id<TARTTChannelConfigRequestDelegate>)delegate;
-(void)cancel;

@end