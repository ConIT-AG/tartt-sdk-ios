//
//  TARTChannelConfig.m
//  Pods
//
//  Created by Thomas Opiolka on 07.10.15.
//
//

#import "TARTTChannelConfig.h"

@implementation TARTTChannelConfig

+ (NSString *)dynamoDBTableName {
    return @"saturnde_ad93b7fe4c_channel";
}

+ (NSString *)hashKeyAttribute {
    return @"key";
}
@end
