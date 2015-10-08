//
//  TarttChannelTests.m
//  TARTT
//
//  Created by Thomas Opiolka on 08.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TARTT/TARTTChannel.h>
#import <TARTT/TARTTChannelConfig.h>
#import <TARTT/TARTTChannelManager.h>

@interface TarttChannelTests : XCTestCase

@end

@implementation TarttChannelTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testDownload {
    // given
    TARTTChannelConfig *config = [TARTTChannelConfig new];
    config.key = @"ChannelKey1";   
    TARTTChannelManager *manager = [[TARTTChannelManager alloc] initWithConfig:config];      
    // when
    TARTTChannel *channel = [manager getChannelInstance];    
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
