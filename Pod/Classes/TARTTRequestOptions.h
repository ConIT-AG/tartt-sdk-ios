//
//  TARTTRequestOptions.h
//  Pods
//
//  Created by Thomas Opiolka on 14.10.15.
//
//

#import <Foundation/Foundation.h>

@interface TARTTRequestOptions : NSObject

-(void)addLanguage:(NSString *)language;
-(void)addEnvironment:(NSString *)env;
-(void)addTargetApi:(NSNumber *)api;
-(void)addTargetType:(NSString *)type;
-(void)changeState:(NSNumber *)state;
-(void)changeChannelKey:(NSString *)channelKey;

-(NSArray *)getLanguage;
-(NSArray *)getEnvironment;
-(NSArray *)getTargetApi;
-(NSArray *)getTargetType;
-(NSNumber *)getState;
-(NSString *)getChannelKey;

-(BOOL)isValid;
@end
