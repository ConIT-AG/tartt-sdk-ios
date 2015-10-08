//
//  TARTChannelConfig.m
//  Pods
//
//  Created by Thomas Opiolka on 07.10.15.
//
//

#import "TARTTChannelConfig.h"

@implementation TARTTChannelConfig
NSString *constTableName;

+ (void)setTable:(NSString *)table {
    constTableName = table;
}

+ (NSString *)dynamoDBTableName {
    return constTableName;
}

+ (NSString *)hashKeyAttribute {
    return @"key";
}
@end
