//
//  TARTTChannelConfigManager.h
//  Pods
//
//
//

#import <Foundation/Foundation.h>
#import "TARTTChannel.h"
#import "TARTTConfig.h"
#import "TARTTErrors.h"
#import "TARTTRequestOptions.h"

/*!
 @protocol TARTTChannelConfigRequestDelegate
 
 @abstract returning information of a config request
 */

@protocol TARTTChannelConfigRequestDelegate <NSObject>

/*!
 @abstract the config request did not make it or didn't find any available channel
 @param error the error that happend while trying to make a config request
 */
-(void)finishedConfigRequestWithError:(NSError *)error;

/*!
 @abstract the config request received multiple channels and cant decide which one to show
 */
-(void)finishedConfigRequestWithMultipleChannels;
/*!
 @abstract the config request found just one channel which can be downloaded directly
 @param config the information needed to create a channel and download the needed files
 */
-(void)finishedConfigRequestWithSuccess:(TARTTConfig *)config;
@end


/*!
 @class TARTTChannelConfigRequest
 
 @abstract the request that is used to get all available channels and the content to download all needed files
 */

@interface TARTTChannelConfigRequest : NSObject


/*!
 @abstract init with parse.com settings and options for filtering
 @param applicationID parse application id
 @param clientKey parse.com clientKey
 @param options options that are used for filtering and selecting the right channel
 */
-(instancetype)initWithApplicationID:(NSString*)applicationID andClientKey:(NSString *)clientKey andOptions:(TARTTRequestOptions *)options;

/*!
 @abstract request the latest Channel from parse.com with given options
 @param delegate the delegate that gets informed 
 @param ignoreMulti directly starts the download of the latest channel if set to YES
 */
-(void)startRequestWithDelegate:(id<TARTTChannelConfigRequestDelegate>)delegate;

/*!
 @abstract if multiple channels are available this function is used to select the one scanned by a QR Scanner
 @param channelKey the name of the channel to load
 @param delegate the delegate which implements TARTTChannelConfigRequestDelegate
 */
-(void)selectChannel:(NSString *)channelKey andDelegate:(id<TARTTChannelConfigRequestDelegate>)delegate;

/*!
 @abstract Possibility to overwrite the language setting
 @param language the language we scanned from outside
 */
-(void)overwriteLanguage:(NSString *)language;

/*!
 @abstract cancels the request
 */
-(void)cancel;

@end