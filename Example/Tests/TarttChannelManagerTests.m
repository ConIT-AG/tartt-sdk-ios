//
//  TarttChannelManagerTests.m
//  TARTT
//
//  Created by Thomas Opiolka on 07.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TARTT/TARTTChannel.h>
#import <TARTT/TARTTChannelManager.h>

@interface TarttChannelManagerTests : XCTestCase<TARTTChannelManagerDelegate>
@property (nonatomic)TARTTChannelManager *manager;
@property (nonatomic) NSString *cacheDirectory;
@end

@implementation TarttChannelManagerTests

- (void)setUp {
    [super setUp];
    self.manager = [[TARTTChannelManager alloc] init];    
    self.cacheDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/"];
    NSString *channelKey = @"testKey";    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *channelDictKey = [NSString stringWithFormat:@"%@-%@",channelKey,kCHANNELKEY];
    [defaults setObject:nil forKey:channelDictKey];
    [defaults synchronize];
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testChannelDirs{    
    // given
    NSString *channelKey = @"testKey";    
    // when
    TARTTChannel *channel = [self.manager getChannel:channelKey];    
    // then
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[self.cacheDirectory stringByAppendingString:@"TARTT/Channels/testKey"]]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:[self.cacheDirectory stringByAppendingString:@"TARTT/Channels/testKey/temp"]]);
    XCTAssertTrue([[NSFileManager defaultManager] fileExistsAtPath:channel.currentPath]);
    XCTAssertNil(channel.lastPath);
}
-(void)testLastChannelDir{
    // given
    NSString *channelKey = @"testKey";    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *channelDictKey = [NSString stringWithFormat:@"%@-%@",channelKey,kCHANNELKEY];
    [defaults setObject:@"simpleTestPath/to/somewhere" forKey:channelDictKey];
    [defaults synchronize];
    TARTTChannel *channel = [self.manager getChannel:channelKey]; 
    XCTAssertEqualObjects(channel.lastPath, @"simpleTestPath/to/somewhere");
}
-(void)testAWSConnection{
    [self.manager requestChannelSetupWithDelegate:self];
}
-(void)finishedWithChannel:(TARTTChannel *)channel{
     XCTAssertNotNil(channel);
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
