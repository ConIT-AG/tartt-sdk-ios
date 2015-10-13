//
//  TARTTChannelDownloader.h
//  Pods
//
//  Created by Thomas Opiolka on 08.10.15.
//
//

#import <Foundation/Foundation.h>
#import "TARTTChannel.h"

FOUNDATION_EXPORT NSString *const TARTTChannelDownloaderErrorDomain;
typedef NS_ENUM(NSInteger, TARTTChannelDownloaderErrorType) {
    TARTTChannelDownloaderErrorDownloadIncomplete
};

@protocol TARTTChannelDownloaderDelegate <NSObject>

- (void) channelDownloadStarted;
- (void) channelDownloadFinishedForChannel:(TARTTChannel *)channel withError:(NSError *)error;
- (void) channelDownloadFinishedForChannel:(TARTTChannel *)channel withErrors:(NSArray *)errors;
- (void) channelDownloadFinishedWithSuccess:(TARTTChannel *)channel;

@optional
- (void) channelDownloadProgress:(long)bytesLoaded ofTotal:(long)bytesTotal;
@end


@interface TARTTChannelDownloader : NSObject

-(instancetype)initWithChannel:(TARTTChannel *)config;

-(void)startDownloadWithDelegate:(id<TARTTChannelDownloaderDelegate>)delegate;
-(void)cancel;

@end
