//
//  TARTTChannelConfigManager.m
//  Pods
//
//  Created by Thomas Opiolka on 08.10.15.
//
//

#import "TARTTChannelConfigRequest.h"
#import "Debug.h"
#import <Parse/Parse.h>


NSString *const TARTTChannelConfigRequestErrorDomain = @"com.takondi.TARTTChannelConfigRequestErrorDomain";
NSString *const TARTTChannelConfigRequestOptionLanguage = @"com.takondi.Language";
NSString *const TARTTChannelConfigRequestOptionEnvironment = @"com.takondi.Environment";
NSString *const TARTTChannelConfigRequestOptionTargetAPI = @"com.takondi.TargetAPI";
NSString *const TARTTChannelConfigRequestOptionTargetType= @"com.takondi.TargetType";
NSString *const TARTTChannelConfigRequestOptionTargetState= @"com.takondi.State";

@interface TARTTChannelConfigRequest()


@property (nonatomic) BOOL canceled;
@property (nonatomic, assign) id<TARTTChannelConfigRequestDelegate> delegate;
@end

@implementation TARTTChannelConfigRequest

-(instancetype)initWithApplicationID:(NSString*)applicationID andClientKey:(NSString *)clientKey{
    self = [super init];
    if (self) {
        [Parse setApplicationId:applicationID  clientKey:clientKey];
        self.options = [NSDictionary new];
    }
    return self;
}
-(void)cancel
{
    self.canceled = YES;    
}
-(void)addOptionsToQuery:(PFQuery *)query{
    [query whereKey:@"state" equalTo:[NSNumber numberWithInt:1]];
    for (NSString* key in self.options) {
        if([key isEqualToString:TARTTChannelConfigRequestOptionLanguage]){
            [query whereKey:@"language" containedIn:[self.options objectForKey:TARTTChannelConfigRequestOptionLanguage]];                
        }else if([key isEqualToString:TARTTChannelConfigRequestOptionEnvironment]){
            [query whereKey:@"envType" containedIn:[self.options objectForKey:TARTTChannelConfigRequestOptionEnvironment]];                
        }else if([key isEqualToString:TARTTChannelConfigRequestOptionTargetAPI]){
            [query whereKey:@"targetApi" containedIn:[self.options objectForKey:TARTTChannelConfigRequestOptionTargetAPI]];                
        }else if([key isEqualToString:TARTTChannelConfigRequestOptionTargetType]){
            [query whereKey:@"targetType" containedIn:[self.options objectForKey:TARTTChannelConfigRequestOptionTargetType]];                
        }else if([key isEqualToString:TARTTChannelConfigRequestOptionTargetState]){
            [query whereKey:@"state" equalTo:[self.options objectForKey:TARTTChannelConfigRequestOptionTargetState]];                
        }       
    }
}

-(void)startRequestWithDelegate:(id<TARTTChannelConfigRequestDelegate>)delegate{
    self.delegate = delegate; 
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    PFQuery *query = [PFQuery queryWithClassName:@"world"];
    [query selectKeys:@[@"channelKey"]];
    [self addOptionsToQuery:query];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(self.canceled)
            return;
        if (!error) 
        {
            DebugLog(@"*** received %lu worlds", [objects count]);
            if([objects count] == 0){
                [self.delegate finishedConfigRequestWithError:[NSError errorWithDomain:TARTTChannelConfigRequestErrorDomain
                                                                                  code:TARTTChannelConfigRequestErrorNoChannels
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
    [self addOptionsToQuery:query];
    [query selectKeys:@[@"content"]];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        if(self.canceled)
            return;
        if (!error) 
        {
            DebugLog(@"*** received %lu worlds", [objects count]);
            if([objects count] == 0){
                [self.delegate finishedConfigRequestWithError:[NSError errorWithDomain:TARTTChannelConfigRequestErrorDomain
                                                                                  code:TARTTChannelConfigRequestErrorNoChannels
                                                                              userInfo:@{NSLocalizedDescriptionKey: @"No Channels available"}]];
            }
            else{
                PFObject *channel = [objects firstObject];
                [self.delegate finishedConfigRequestWithSuccess:channel];         
            }
        } 
        else {
            // Log details of the failure
            DebugLog(@"*** Error: %@ %@", error, [error userInfo]);
            [self.delegate finishedConfigRequestWithError:error];
        }
    }];

    
}

@end
