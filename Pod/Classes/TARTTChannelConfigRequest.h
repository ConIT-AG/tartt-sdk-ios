//
//  TARTTChannelConfigManager.h
//  Pods
//
//  Created by Thomas Opiolka on 08.10.15.
//
//

#import <Foundation/Foundation.h>
#import "TARTTChannel.h"

@protocol TARTTChannelConfigRequestDelegate <NSObject>

-(void)finishedConfigRequestWithError:(NSError *)error;
-(void)finishedConfigRequestWithSuccess:(NSArray *)configs;

@end

@interface TARTTChannelConfigRequest : NSObject

-(instancetype)initWithPoolID:(NSString*)poolID andRegion:(AWSRegionType)region andTable:(NSString *)table;
-(void)startRequestWithDelegate:(id<TARTTChannelConfigRequestDelegate>)delegate;
-(void)cancel;

@end
