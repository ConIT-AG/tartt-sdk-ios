//
//  TARTTChannelManager.m
//  Pods
//
//  Created by Thomas Opiolka on 07.10.15.
//
//

#import "TARTTChannelManager.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "TARTTChannelConfig.h"
#import "Debug.h"

#define kCHANNELBASEDIR @"TARTT/Channels"


@interface TARTTChannelManager ()

@property (nonatomic) NSString *cacheDirectory;
@property (nonatomic, assign) id<TARTTChannelManagerDelegate> delegate;

@end



@implementation TARTTChannelManager

-(instancetype)init
{
    self = [super init];
    if (self) {
        self.cacheDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/"];
    }
    return self;
}
-(void)requestChannelSetupWithDelegate:(id<TARTTChannelManagerDelegate>)delegate
{
    self.delegate = delegate;
    AWSRegionType const CognitoRegionType = AWSRegionEUWest1; 
    AWSRegionType const DefaultServiceRegionType = AWSRegionEUWest1; 
    NSString *const CognitoIdentityPoolId = @"eu-west-1:99e5483a-51cf-4c6f-a8d3-b7a5cee36b98";
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:CognitoRegionType
                                                                                                    identityPoolId:CognitoIdentityPoolId];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:DefaultServiceRegionType
                                                                         credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;
    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    scanExpression.limit = @100;
    
    [[dynamoDBObjectMapper scan:[TARTTChannelConfig class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if (task.error) {
             DebugLog(@"The request failed. Error: [%@]", task.error);
             [self.delegate finishedInitWithError:task.error];
         }
         if (task.exception) {
             DebugLog(@"The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             if([paginatedOutput.items count] > 1)
             {
                 [self.delegate finishedWithMultipleChannels];
             }else{
                 TARTTChannelConfig *config = [paginatedOutput.items firstObject];
                 TARTTChannel *channel = [self getChannel:config.key];
                 channel.config = config;
                 [self.delegate finishedWithChannel:channel];
             }
         }
         return nil;
     }];
        
    
    
}
-(TARTTChannel *)getChannel:(NSString *)channelKey;{

    TARTTChannel *channel = [[TARTTChannel alloc] initWithKey:channelKey]; 
    channel.mainPath = [self getChannelPath:channelKey];
    channel.currentPath = [self getChannelPath:channelKey];
    channel.tempPath = [self getTempPath:channelKey];
    channel.lastPath = [self getLastPath:channelKey];
    return channel;
}

-(NSString *)getChannelPath:(NSString *)channelKey
{
    NSString *channelPath = [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",kCHANNELBASEDIR,channelKey]];    
    if([self ensureDirExists:channelPath])
        return channelPath;
    return nil; 
}-(NSString *)getLastPath:(NSString *)channelKey
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *channelDictKey = [NSString stringWithFormat:@"%@-%@",channelKey,kCHANNELKEY];   
    return [defaults objectForKey:channelDictKey];
}
-(NSString *)getTempPath:(NSString *)channelKey
{
    NSString *temp = [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/temp",kCHANNELBASEDIR,channelKey]];
    if([self ensureDirExists:temp])
        return temp;
    return nil;
}
-(NSString *)createNewChannelVersion:(NSString *)channelKey{
    NSString *channelPath = [self getChannelPath:channelKey];
    NSString *newVersionPath = [channelPath stringByAppendingString:[[NSUUID UUID] UUIDString]];
    if([self ensureDirExists:newVersionPath])
        return newVersionPath;
    return nil;
}

-(BOOL)ensureDirExists:(NSString *)path
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];    
    if(![fileManager fileExistsAtPath:path]){
        [fileManager createDirectoryAtPath:path
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
    }
    return error == nil;
}

@end
