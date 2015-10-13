//
//  TARTTConfig.h
//  Pods
//
//  Created by Thomas Opiolka on 13.10.15.
//
//

#import <Parse/Parse.h>

@interface TARTTConfig : PFObject<PFSubclassing>

@property (nonatomic, strong) NSString *channelKey;
@property (nonatomic, strong) NSDictionary *content;

+(NSString *)parseClassName;
@end
