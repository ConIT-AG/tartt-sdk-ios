//
//  TARTTConfig.h
//  Pods
//
//
//

#import <Parse/Parse.h>

/*!
 @class TARTTConfig
 @abstract the parse configuration model
 it holds the channlekey and the content.
 the content holds all files that have to be downloaded to install the channel
 */
@interface TARTTConfig : PFObject<PFSubclassing>

/* the identifier of the channel  */
@property (nonatomic, strong) NSString *channelKey;
/* the content which holds all files */
@property (nonatomic, strong) NSDictionary *content;

/* specifies the table in parse that should be queried */
+(NSString *)parseClassName;
@end
