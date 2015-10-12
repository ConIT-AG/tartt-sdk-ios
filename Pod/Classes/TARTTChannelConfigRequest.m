//
//  TARTTChannelConfigManager.m
//  Pods
//
//  Created by Thomas Opiolka on 08.10.15.
//
//

#import "TARTTChannelConfigRequest.h"
#import <AWSCore/AWSCore.h>
#import <AWSDynamoDB/AWSDynamoDB.h>
#import "Debug.h"

@interface TARTTChannelConfigRequest()

@property (nonatomic) NSString *poolID;
@property (nonatomic) BOOL canceled;
@property (nonatomic) AWSRegionType region;
@property (nonatomic, assign) id<TARTTChannelConfigRequestDelegate> delegate;
@end

@implementation TARTTChannelConfigRequest

-(instancetype)initWithPoolID:(NSString*)poolID andRegion:(AWSRegionType)region andTable:(NSString *)table{
    self = [super init];
    if (self) {
        self.poolID = poolID;
        self.region = region;
        [TARTTChannelConfig setTable:table];
    }
    return self;
}
-(void)cancel
{
    self.canceled = YES;    
}

-(void)startRequestWithDelegate:(id<TARTTChannelConfigRequestDelegate>)delegate{
    self.delegate = delegate;     

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    AWSCognitoCredentialsProvider *credentialsProvider = [[AWSCognitoCredentialsProvider alloc] initWithRegionType:self.region 
                                                                                                    identityPoolId:self.poolID];
    AWSServiceConfiguration *configuration = [[AWSServiceConfiguration alloc] initWithRegion:self.region
                                                                         credentialsProvider:credentialsProvider];
    AWSServiceManager.defaultServiceManager.defaultServiceConfiguration = configuration;    
    AWSDynamoDBObjectMapper *dynamoDBObjectMapper = [AWSDynamoDBObjectMapper defaultDynamoDBObjectMapper];
    
    AWSDynamoDBScanExpression *scanExpression = [AWSDynamoDBScanExpression new];
    DebugLog(@"*** Start DynamoDB Call with PoolID %@ ",self.poolID);
    [[dynamoDBObjectMapper scan:[TARTTChannelConfig class]
                     expression:scanExpression]
     continueWithBlock:^id(AWSTask *task) {
         if(self.canceled){
             DebugLog(@"*** Config Request Canceled");
             return nil;
         }
         if (task.error) {
             DebugLog(@"*** The request failed. Error: [%@]", task.error);
             [self.delegate finishedConfigRequestWithError:task.error];
         }
         if (task.exception) {
             DebugLog(@"*** The request failed. Exception: [%@]", task.exception);
         }
         if (task.result) {             
             AWSDynamoDBPaginatedOutput *paginatedOutput = task.result;
             DebugLog(@"*** DynamoDB Call received with %lu configs",[paginatedOutput.items count]);
             [self.delegate finishedConfigRequestWithSuccess:paginatedOutput.items];             
         }
         [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
         return nil;
     }];   
}

@end
