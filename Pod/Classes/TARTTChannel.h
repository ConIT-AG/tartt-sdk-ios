//
//  TARTTChannel.h
//  Pods
//
//  Created by Thomas Opiolka on 06.10.15.
//
//

#import <Foundation/Foundation.h>

#define kERROR_FILEDOWNLOAD  100
#define kERROR_SOMETHINGELSE  200

@protocol TARTTChannelDelegate <NSObject>

- (void) channelStartedDownload;
- (void) channelFinishedWithError:(NSError *)error;
- (void) channelFinishedWithErrors:(NSArray *)errors;
- (void) channelFinishedWithSuccess;

@optional
- (void) channelProgressLoadedBytes:(long)bytesLoaded ofTotal:(long)bytesTotal;
@end


@interface TARTTChannel : NSObject

-(instancetype)initWithKey:(NSString *)key andDelegate:(id<TARTTChannelDelegate>)delegate;

-(void)startDownloadIfNeeded;

@end
