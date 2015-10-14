//
//  TARTTChannelConfigManager.m
//  Pods
//
//
//

#import "TARTTChannelConfigRequest.h"
#import "Debug.h"
#import <Parse/Parse.h>

@interface TARTTChannelConfigRequest()

@property (nonatomic) BOOL canceled;
@property (nonatomic, assign) id<TARTTChannelConfigRequestDelegate> delegate;
@property (nonatomic) TARTTRequestOptions *options;
@end

@implementation TARTTChannelConfigRequest

-(instancetype)initWithApplicationID:(NSString*)applicationID andClientKey:(NSString *)clientKey andOptions:(TARTTRequestOptions *)options{
    self = [super init];
    if (self) {
        [Parse setApplicationId:applicationID  clientKey:clientKey];
        self.options = options;
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
    
    PFQuery *query = [PFQuery queryWithClassName:@"world"];
    [query selectKeys:@[@"channelKey"]];
    query = [self addOptionsToQuery:query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(self.canceled)
            return;
        if (!error) 
        {
            DebugLog(@"*** received %lu worlds", [objects count]);
            if([objects count] == 0){
                [self.delegate finishedConfigRequestWithError:[NSError errorWithDomain:TARTTErrorDomain
                                                                                  code:TARTTErrorNoChannelsAvailable
                                                                              userInfo:@{NSLocalizedDescriptionKey: @"No Channels available"}]];
            }else if([objects count] > 1)
            {
                [self.delegate finishedConfigRequestWithMultipleChannels];
            }
            else{
                PFObject *channel = [objects firstObject];
                [self selectChannel:[channel objectForKey:@"channelKey"] andDelegate:self.delegate];
            }
        } 
        else {
            // Log details of the failure
            DebugLog(@"*** Error: %@ %@", error, [error userInfo]);
            [self.delegate finishedConfigRequestWithError:error];
        }
    }];    
}


-(void)selectChannel:(NSString *)channelKey andDelegate:(id<TARTTChannelConfigRequestDelegate>)delegate{
    self.delegate = delegate; 
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    PFQuery *query = [PFQuery queryWithClassName:@"world"];
    [query whereKey:@"channelKey" equalTo:channelKey];
    query = [self addOptionsToQuery:query];
    [query selectKeys:@[@"channelKey",@"content"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(self.canceled)
            return;
        if (!error) 
        {
            DebugLog(@"*** received %lu worlds", [objects count]);
            if([objects count] == 0){
                [self.delegate finishedConfigRequestWithError:[NSError errorWithDomain:TARTTErrorDomain
                                                                                  code:TARTTErrorNoChannelsAvailable
                                                                              userInfo:@{NSLocalizedDescriptionKey: @"No Channels available"}]];
            }
            else{
                TARTTConfig *config = [objects firstObject];
                [self.delegate finishedConfigRequestWithSuccess:config];         
            }
        } 
        else {
            // Log details of the failure
            DebugLog(@"*** Error: %@ %@", error, [error userInfo]);
            [self.delegate finishedConfigRequestWithError:error];
        }
    }];    
}
-(PFQuery *)addOptionsToQuery:(PFQuery *)query
{
    if(self.options == nil)
        return query;
    [query whereKey:@"language" containedIn:[self.options getLanguage]];                
    [query whereKey:@"envType" containedIn:[self.options getEnvironment]];
    [query whereKey:@"targetApi" containedIn:[self.options getTargetApi]];    
    [query whereKey:@"targetType" containedIn:[self.options getTargetType]];  
    [query whereKey:@"state" equalTo:[self.options getState]];                 
    [query orderByDescending:@"updatedAt"];
    return query;
}

@end
