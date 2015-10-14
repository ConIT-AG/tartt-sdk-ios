//
//  TARTTConfig.h
//  Pods
//
//
//

#import <Parse/Parse.h>

@interface TARTTConfig : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *channelKey;
@property (nonatomic, strong) NSDictionary *content;

+(NSString *)parseClassName;
@end
