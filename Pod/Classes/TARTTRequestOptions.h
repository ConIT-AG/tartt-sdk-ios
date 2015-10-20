//
//  TARTTRequestOptions.h
//  Pods
//
//  Created by Thomas Opiolka on 14.10.15.
//
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, TARTTStateType) {
    TARTTStateInActive,
    TARTTStateActive,
    TARTTStateArchive,
};

typedef NS_ENUM(NSInteger, TARTTTargetType) {
    TARTTTargetTypeMainAndDetail,
    TARTTTargetTypeMain,
};

typedef NS_ENUM(NSInteger, TARTTEnvironment) {
    TARTTEnvironmentTest,
    TARTTEnvironmentProduction,
};

@interface TARTTRequestOptions : NSObject

-(void)addLanguage:(NSString *)language;
-(void)addEnvironment:(TARTTEnvironment)env;
-(void)addTargetApi:(NSNumber *)api;
-(void)addTargetType:(TARTTTargetType)type;
-(void)changeState:(TARTTStateType) state;
-(void)changeChannelKey:(NSString *)channelKey;
-(void)changeTable:(NSString *)table;

-(NSArray *)getLanguage;
-(NSArray *)getEnvironment;
-(NSArray *)getTargetApi;
-(NSArray *)getTargetType;
-(NSNumber *)getState;
-(NSString *)getChannelKey;
-(NSString *)getTable;

-(BOOL)isValid;
@end
