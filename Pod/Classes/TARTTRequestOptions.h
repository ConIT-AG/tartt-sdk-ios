//
//  TARTTRequestOptions.h
//  Pods
//
//  Created by Thomas Opiolka on 14.10.15.
//
//

#import <Foundation/Foundation.h>


/*!
 @typedef TARTTStateType
 @abstract Tartt channel state types 
 */
typedef NS_ENUM(NSInteger, TARTTStateType) {
    TARTTStateInActive,
    TARTTStateActive,
    TARTTStateArchive,
};
/*!
 @typedef TARTTTargetType 
 @abstract Tartt channel target types 
 currently there are two options
 "MainandDetail" means the main image and the 4 detail images will be loaded
 "Main" means just the main image will be loaded. 
 The second usecase is for low perfomant devices like iphone 4 
 */
typedef NS_ENUM(NSInteger, TARTTTargetType) {
    TARTTTargetTypeMainAndDetail,
    TARTTTargetTypeMain,
};
/*!
 @typedef TARTTEnvironment
 @abstract Tartt channel environments 
 */
typedef NS_ENUM(NSInteger, TARTTEnvironment) {
    TARTTEnvironmentTest,
    TARTTEnvironmentProduction,
};

/*!
 @class TARTTRequestOptions
 @abstract the option class for the parse request 
 */
@interface TARTTRequestOptions : NSObject

/*!
 @abstract add a language in iso 2 digit code.
 can handle multiple
 It will be converted to lowercase
 @param language the iso code (2 digits)
 */
-(void)addLanguage:(NSString *)language;

/*!
 @abstract add an environemnt to the options
 can handle multiple
 @param env the environment that we are currenlty in
 */
-(void)addEnvironment:(TARTTEnvironment)env;
-(void)forceEnvironment:(NSString *)env;

/*!
 @abstract add a api that we are currenlty running
 !!! Meant is here the script API not the framework API !!!
 @param api the current script api like 3
 */
-(void)addTargetApi:(NSNumber *)api;

/*!
 @abstract add a target type to the options
 @param type the current target type that is requested
 */
-(void)addTargetType:(TARTTTargetType)type;
-(void)forceTargetType:(NSString *)type;

/*!
 @abstract set the current state that the channel should have
 @param state the state we want the channel to be in
 */
-(void)changeState:(TARTTStateType) state;
-(void)forceState:(NSNumber *)state;

/*!
 @abstract set the channel Key if explicit if there are more than one available
 @param channelKey the identiefier of the channel
 */
-(void)changeChannelKey:(NSString *)channelKey;

/*!
 @abstract set the table that should be selected for queries
 @param table the name of the table
 */
-(void)changeTable:(NSString *)table;


/// GETTER METHODS
-(NSArray *)getLanguage;
-(NSArray *)getEnvironment;
-(NSArray *)getTargetApi;
-(NSArray *)getTargetType;
-(NSNumber *)getState;
-(NSString *)getChannelKey;
-(NSString *)getTable;


/*!
 @abstract is the options object in a valid state
 means that at least one parameter for each option must be set
 @return yes if the object is in a valid state
 */
-(BOOL)isValid;
@end
