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

@property (nonatomic, strong) NSString *mainPath;
@property (nonatomic, strong) NSString *currentPath;
@property (nonatomic, strong) NSString *lastPath;
@property (nonatomic, strong) NSString *tempPath;

-(instancetype)initWithKey:(NSString *)key;

-(void)initChannelWithDelegate:(id<TARTTChannelDelegate>)delegate;

@end
