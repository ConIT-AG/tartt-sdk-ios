//
//  TARTTChannelDownloader.h
//  Pods
//
//
//

#import <Foundation/Foundation.h>
#import "TARTTChannel.h"


/*!
 @@protocol TARTTChannelDownloaderDelegate
 
 @abstract the delegation methods needed to display a progress
 */
@protocol TARTTChannelDownloaderDelegate <NSObject>

/*!
 @abstract this method is only called if a download is needed. Might be skipped if all files in cache are up to date
 */
- (void) channelDownloadStarted;
/*!
 @abstract is called when at least one error is thrown while downloading
 @param channel the current channel model
 @param error the error that canceled this download
 */
- (void) channelDownloadFinishedForChannel:(TARTTChannel *)channel withError:(NSError *)error;
/*!
 @abstract download finished with success
 @param channel the current channel model
 */
- (void) channelDownloadFinishedWithSuccess:(TARTTChannel *)channel;

///--------------------------------------
/// @name optional methods
///--------------------------------------
@optional
/*!
 @abstract progress information of the current running download
 @param bytesLoaded the currently loaded bytes
 @param bytesTotal the total bytes that will be loaded
 */
- (void) channelDownloadProgress:(long)bytesLoaded ofTotal:(long)bytesTotal;
/*!
 @abstract debug method to be able to display all errors that happend in the download
 @param channel the current channel model
 @param errors an array of errors for debug purposes only
 */
- (void) channelDownloadFinishedForChannel:(TARTTChannel *)channel withErrors:(NSArray *)errors;

@end

/*!
 @class TARTTChannelDownloader
 
 @abstract this class is able to download a channel. 
 Downloaded files will be stored in the cache directory of the device and reused for the 
 next download if they haved changed since (based on MD5 hash)
 */

@interface TARTTChannelDownloader : NSObject

/*!
 @abstract initialises the downloader
 @param channel the channel model to download
 */
-(instancetype)initWithChannel:(TARTTChannel *)channel;

/*!
 @abstract triggers the actual download if it is neccessary
 @param delegate the delegate that responses to TARTTChannelDownloaderDelegate
 */
-(void)startDownloadWithDelegate:(id<TARTTChannelDownloaderDelegate>)delegate;
/*!
 @abstract cancels the download
 */
-(void)cancel;

@end
