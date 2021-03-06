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

+ (NSNumber *)initialize:(NSString *)appID andClientKey:(NSString *)clientKey
{
    static NSNumber *sharedInstance = false;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [NSNumber numberWithBool:YES];
        [Parse setApplicationId:appID  clientKey:clientKey];
    });
    return sharedInstance;
}

-(instancetype)initWithApplicationID:(NSString*)applicationID andClientKey:(NSString *)clientKey andOptions:(TARTTRequestOptions *)options{
    self = [super init];
    if (self) {
        [TARTTChannelConfigRequest initialize:applicationID andClientKey:clientKey];        
        self.options = options;
    }
    return self;
}
-(void)cancel
{
    self.canceled = YES;    
}


-(void)startRequestWithDelegate:(id<TARTTChannelConfigRequestDelegate>)delegate
{
    self.canceled = NO;
    self.delegate = delegate; 
    if(![self.options isValid])
    {
        [self performSelectorOnMainThread:@selector(invokeFinishedConfigRequestWithError:) 
                               withObject:[NSError errorWithDomain:TARTTErrorDomain
                                                              code:TARTTErrorMissingArguments
                                                          userInfo:@{NSLocalizedDescriptionKey: @"Missing crutial options for request"}] 
                            waitUntilDone:YES];
        return;
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];    
    PFQuery *query = [PFQuery queryWithClassName:[self.options getTable]];
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
                [self performSelectorOnMainThread:@selector(invokeFinishedConfigRequestWithError:) 
                                       withObject:[NSError errorWithDomain:TARTTErrorDomain
                                                                      code:TARTTErrorNoChannelsAvailable
                                                                  userInfo:@{NSLocalizedDescriptionKey: @"No Channels available"}] 
                                    waitUntilDone:YES];
                
            }else if([objects count] > 1 && ![self.options shouldIgnoreMultiChannels])
            {
                [self performSelectorOnMainThread:@selector(invokeFinishedConfigRequestMultipleChannels) withObject:nil waitUntilDone:YES];
            }
            else{
                if([objects count] > 1)
                    DebugLog(@"*** ignoring mutliple Channels and start download the latest");
                PFObject *channel = [objects firstObject];
                [self selectChannel:[channel objectForKey:@"channelKey"] andDelegate:self.delegate];
            }
        } 
        else 
        {
            DebugLog(@"*** Error: %@ %@", error, [error userInfo]);
            [self performSelectorOnMainThread:@selector(invokeFinishedConfigRequestWithError:) withObject:error waitUntilDone:YES];
        }
    }];    
}


-(void)selectChannel:(NSString *)channelKey andDelegate:(id<TARTTChannelConfigRequestDelegate>)delegate{
    self.delegate = delegate; 
    self.canceled = NO;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    PFQuery *query = [PFQuery queryWithClassName:[self.options getTable]];
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
                [self performSelectorOnMainThread:@selector(invokeFinishedConfigRequestWithError:) 
                                       withObject:[NSError errorWithDomain:TARTTErrorDomain
                                                                      code:TARTTErrorCouldNotSelectChannel
                                                                  userInfo:@{NSLocalizedDescriptionKey: @"Channel could not be selected"}] 
                                    waitUntilDone:YES];
            }
            else{
                TARTTConfig *config = [objects firstObject];
                [self performSelectorOnMainThread:@selector(invokeFinishedConfigRequestWithSuccess:) withObject:config waitUntilDone:YES];
            }
        } 
        else 
        {        
            DebugLog(@"*** Error: %@ %@", error, [error userInfo]);
            [self performSelectorOnMainThread:@selector(invokeFinishedConfigRequestWithError:) withObject:error waitUntilDone:YES];
        }
    }];    
}
-(void)overwriteLanguage:(NSString *)language{
    
}
-(PFQuery *)addOptionsToQuery:(PFQuery *)query
{
    if(self.options == nil)
        return query;
    [query whereKey:@"language" containedIn:[self.options getLanguage]];                
    [query whereKey:@"envType" containedIn:[self.options getEnvType]];
    [query whereKey:@"targetApi" containedIn:[self.options getTargetApi]];    
    [query whereKey:@"targetType" containedIn:[self.options getTargetType]];  
    [query whereKey:@"state" equalTo:[self.options getState]];                 
    [query orderByDescending:@"updatedAt"];
    
    DebugLog(@"*** Query Parse with Parameters: Language:%@ Env:%@ TargetApi:%@ TargetType:%@ State:%@", [[self.options getLanguage] firstObject], 
             [[self.options getEnvType] firstObject],
             [[self.options getTargetApi] firstObject], 
             [[self.options getTargetType] firstObject], 
             [self.options getState]);
    return query;
}

-(void)invokeFinishedConfigRequestWithSuccess:(TARTTConfig *)config{
    [self.delegate finishedConfigRequestWithSuccess:config];
}
-(void)invokeFinishedConfigRequestWithError:(NSError *)error{
    [self.delegate finishedConfigRequestWithError:error];
}
-(void)invokeFinishedConfigRequestMultipleChannels{
    [self.delegate finishedConfigRequestWithMultipleChannels];
}
@end