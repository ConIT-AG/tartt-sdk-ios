//
//  TarttChannelDownloaderTests.m
//  TARTT
//
//  Created by Thomas Opiolka on 08.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TARTT/TARTTChannel.h>
#import <TARTT/TARTTConfig.h>
#import <TARTT/TARTTChannelManager.h>
#import <TARTT/TARTTChannelDownloader.h>


@interface TarttChannelDownloaderTests : XCTestCase<TARTTChannelDownloaderDelegate>
@property (nonatomic) BOOL isDone;
@property (nonatomic) BOOL isError;
@property (nonatomic) NSString *cacheDirectory;
@property (nonatomic) TARTTConfig *config;
@property (nonatomic) TARTTConfig *wrongConfig;
@end

@implementation TarttChannelDownloaderTests

- (void)setUp {
    [super setUp];
    self.cacheDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/"];
    NSMutableDictionary *file1 = [NSMutableDictionary dictionary];
    [file1 setObject:@"/assets/images" forKey:@"dirname"];
    [file1 setObject:@"http://manorplus.dev.takondi-hosting.com/tests/jsonfortartt/world/studio/assets/images/social-media-youtube.png" forKey:@"url"];
    [file1 setObject:[NSNumber numberWithInt:12438] forKey:@"filesize"];
    [file1 setObject:@"6308ce9badf1c3b9dd5e2a0217e23879" forKey:@"md5"];
    
    NSMutableDictionary *file2 = [NSMutableDictionary dictionary];
    [file2 setObject:@"/js" forKey:@"dirname"];
    [file2 setObject:@"http://manorplus.dev.takondi-hosting.com/tests/jsonfortartt/world/studio/js/converter.js" forKey:@"url"];
    [file2 setObject:[NSNumber numberWithInt:24873] forKey:@"filesize"];
    [file2 setObject:@"3a1648b4daa5e16861789a7621a5a18c" forKey:@"md5"];    
    
    TARTTConfig *config = [TARTTConfig new];
    config.channelKey = @"channelDownloadTest";
    config.content = [NSDictionary dictionaryWithObjects:@[[NSArray arrayWithObjects:file1, file2, nil]] forKeys: @[@"files"]];
    self.config = config;
    
    
    TARTTConfig *config2 = [TARTTConfig new];
    NSMutableDictionary *file3 = [NSMutableDictionary dictionary];
    [file3 setObject:@"/assets/images" forKey:@"dirname"];
    [file3 setObject:@"http://manorplus.dev.takondi-hosting.com/tests/jsonfortartt/world/studio/assets/images/social-media-youtube.png1" forKey:@"url"];
    [file3 setObject:[NSNumber numberWithInt:12438] forKey:@"filesize"];
    [file3 setObject:@"6308ce9badf1c3b9dd5e2a0217e23879" forKey:@"md5"];
    config2.channelKey = @"channelDownloadTest";
    config2.content = [NSDictionary dictionaryWithObjects:@[[NSArray arrayWithObjects:file1, file2, file3, nil]] forKeys: @[@"files"]];
    self.wrongConfig = config2;
    
}

- (void)tearDown {
    [super tearDown];
}

- (void)testChannelDownload {
    NSError *error;
    TARTTChannel *channel  = [[TARTTChannelManager defaultManager] prepareChannelWithConfig:self.config error:&error];
    
   [[NSFileManager defaultManager] removeItemAtPath:[self.cacheDirectory stringByAppendingString:@"TARTT/Channels/"] error:nil];
    
    TARTTChannelDownloader *downloader = [[TARTTChannelDownloader alloc] initWithChannel:channel];
    [downloader startDownloadWithDelegate:self];    
    
    self.isDone = NO;
    NSDate *untilDate;
    while(!self.isDone){
        untilDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        [[NSRunLoop currentRunLoop] runUntilDate:untilDate];
        NSLog(@"poll...");
    }    
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[channel.tempPath stringByAppendingString:@"/assets/images/social-media-youtube.png"]]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[channel.tempPath stringByAppendingString:@"/js/converter.js"]]);

    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[channel.currentPath stringByAppendingString:@"/assets/images/social-media-youtube.png"]]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[channel.currentPath stringByAppendingString:@"/js/converter.js"]]);
    
    [[TARTTChannelManager defaultManager] cleanUpChannel:channel error:&error];
    
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[channel.tempPath stringByAppendingString:@"/assets/images/social-media-youtube.png"]]);
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[channel.tempPath stringByAppendingString:@"/js/converter.js"]]);
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:channel.tempPath]);
    
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[channel.currentPath stringByAppendingString:@"/assets/images/social-media-youtube.png"]]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[channel.currentPath stringByAppendingString:@"/js/converter.js"]]);
    
    [[TARTTChannelManager defaultManager] deleteChannel:channel error:&error];
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:channel.mainPath]);
    XCTAssertNil(error);
}
- (void)testChannelCleanupOlderVersions{
      
    NSError *error;
    TARTTChannel *channel  = [[TARTTChannelManager defaultManager] prepareChannelWithConfig:self.config error:&error];
    
    [[NSFileManager defaultManager] removeItemAtPath:[self.cacheDirectory stringByAppendingString:@"TARTT/Channels/"] error:nil];
    
    TARTTChannelDownloader *downloader = [[TARTTChannelDownloader alloc] initWithChannel:channel];
    [downloader startDownloadWithDelegate:self];    
    
    self.isDone = NO;
    NSDate *untilDate;
    while(!self.isDone){
        untilDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        [[NSRunLoop currentRunLoop] runUntilDate:untilDate];
        NSLog(@"poll...");
    }       
    NSString *currenPath = channel.currentPath;
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:currenPath]);
    [[TARTTChannelManager defaultManager] cleanUpChannel:channel error:&error];   
    
    channel  = [[TARTTChannelManager defaultManager] prepareChannelWithConfig:self.config error:&error];    
    downloader = [[TARTTChannelDownloader alloc] initWithChannel:channel];
    [downloader startDownloadWithDelegate:self];   
    self.isDone = NO;    
    while(!self.isDone){
        untilDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        [[NSRunLoop currentRunLoop] runUntilDate:untilDate];
        NSLog(@"poll...");
    }
    [[TARTTChannelManager defaultManager] cleanUpChannel:channel error:&error];    
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:currenPath]);
    XCTAssertNil(error);
}



- (void)testChannelDownloadFailes {
        
    NSError *error;
    TARTTChannel *channel  = [[TARTTChannelManager defaultManager] prepareChannelWithConfig:self.wrongConfig error:&error];
    
    [[NSFileManager defaultManager] removeItemAtPath:[self.cacheDirectory stringByAppendingString:@"TARTT/Channels/"] error:nil];    
    
    TARTTChannelDownloader *downloader = [[TARTTChannelDownloader alloc] initWithChannel:channel];
    [downloader startDownloadWithDelegate:self];    
    
    self.isDone = NO;
    self.isError = NO;
    NSDate *untilDate;
    while(!self.isDone){
        untilDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        [[NSRunLoop currentRunLoop] runUntilDate:untilDate];
        NSLog(@"poll...");
    }    
    XCTAssertTrue(self.isError);
}
-(void)testChannelDownloadCancel{   
    
    NSError *error;
    TARTTChannel *channel  = [[TARTTChannelManager defaultManager] prepareChannelWithConfig:self.config error:&error];
    
    [[NSFileManager defaultManager] removeItemAtPath:[self.cacheDirectory stringByAppendingString:@"TARTT/Channels/"] error:nil];    
    
    self.isDone = NO;
    self.isError = NO;
    
    TARTTChannelDownloader *downloader = [[TARTTChannelDownloader alloc] initWithChannel:channel];
    [downloader startDownloadWithDelegate:self];    
    
    [downloader cancel];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.0]];

    
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[channel.tempPath stringByAppendingString:@"/assets/images/social-media-youtube.png"]]);
    XCTAssertFalse([[NSFileManager defaultManager] fileExistsAtPath:[channel.currentPath stringByAppendingString:@"/assets/images/social-media-youtube.png"]]);   
}


-(void)channelDownloadStarted{
}
-(void)channelDownloadFinishedWithSuccess:(TARTTChannel *)channel{
    self.isDone = YES;
}
-(void)channelDownloadFinishedForChannel:(TARTTChannel *)channel withError:(NSError *)error{
    self.isError = YES;
    self.isDone = YES;
}
-(void)channelDownloadFinishedForChannel:(TARTTChannel *)channel withErrors:(NSArray *)errors{

}
@end