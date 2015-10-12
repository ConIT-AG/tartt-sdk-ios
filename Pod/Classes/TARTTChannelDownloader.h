//
//  TARTTChannelDownloader.h
//  Pods
//
//  Created by Thomas Opiolka on 08.10.15.
//
//

#import <Foundation/Foundation.h>
#import "TARTTChannel.h"

#define kERROR_FILEDOWNLOAD  100
#define kERROR_SOMETHINGELSE  200

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
