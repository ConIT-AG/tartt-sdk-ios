//
//  TarttChannelManagerTests.m
//  TARTT
//
//  Created by Thomas Opiolka on 07.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TARTT/TARTTChannel.h>
#import <TARTT/TARTTConfig.h>
#import <TARTT/TARTTChannelManager.h>


@interface TarttChannelManagerTests : XCTestCase
@property (nonatomic) NSString *cacheDirectory;
@end

@implementation TarttChannelManagerTests

- (void)setUp {
    [super setUp];   
      
    self.cacheDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/"];
    NSString *channelKey = @"ChannelKey1";      
    [[TARTTChannelManager defaultManager] saveLastPath:nil forChannel:channelKey];    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testChannelDirs{    
    // given
    TARTTConfig *config = [TARTTConfig new];
    config.channelKey = @"ChannelKey1";
    [[NSFileManager defaultManager] removeItemAtPath:[self.cacheDirectory stringByAppendingString:@"TARTT/Channels/"] error:nil];
    
    // when
    NSError *error;
    TARTTChannel *channel = [[TARTTChannelManager defaultManager] prepareChannelWithConfig:config error:&error];    
    // then
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[self.cacheDirectory stringByAppendingString:@"TARTT/Channels/ChannelKey1"]]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[self.cacheDirectory stringByAppendingString:@"TARTT/Channels/ChannelKey1/temp"]]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:channel.currentPath]);
    XCTAssertNil(channel.lastPath);
}
-(void)testLastChannelDir{
    // given
    NSString *channelKey = @"ChannelKey1"; 
    [[TARTTChannelManager defaultManager] saveLastPath:@"simpleTestPath/to/somewhere" forChannel:channelKey];

    TARTTConfig *config = [TARTTConfig new];
    config.channelKey = @"ChannelKey1";     
    
    NSError *error;
    TARTTChannel *channel = [[TARTTChannelManager defaultManager] prepareChannelWithConfig:config error:&error];   
    XCTAssertEqualObjects(channel.lastPath, @"simpleTestPath/to/somewhere");
}
@end
