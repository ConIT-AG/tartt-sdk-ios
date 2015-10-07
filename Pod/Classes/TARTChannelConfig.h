//
//  TARTChannelConfig.h
//  Pods
//
//  Created by Thomas Opiolka on 07.10.15.
//
//
#import <Foundation/Foundation.h>
#import <AWSDynamoDB/AWSDynamoDB.h>

@interface TARTChannelConfig : AWSDynamoDBObjectModel<AWSDynamoDBModeling>

@property (nonatomic, strong) NSString *key;
@property (nonatomic, strong) NSArray *language;
@property (nonatomic, strong) NSArray *wikitude_sdk_version;
@property (nonatomic, strong) NSArray *type;
@property (nonatomic, strong) NSArray *files;

@end
