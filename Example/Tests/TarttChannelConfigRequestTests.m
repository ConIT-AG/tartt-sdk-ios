//
//  TarttChannelConfigManagerTests.m
//  TARTT
//
//  Created by Thomas Opiolka on 08.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TARTT/TARTTChannelConfigRequest.h>

@interface TarttChannelConfigRequestTests : XCTestCase<TARTTChannelConfigRequestDelegate>
@property (nonatomic) BOOL isDone;
@property (nonatomic) NSArray *configs;
@end

@implementation TarttChannelConfigRequestTests

- (void)setUp {
    [super setUp];    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testAWSConfig {    
    
    TARTTChannelConfigRequest *request = [[TARTTChannelConfigRequest alloc] initWithPoolID:@"eu-west-1:99e5483a-51cf-4c6f-a8d3-b7a5cee36b98" 
                                                                                 andRegion:AWSRegionEUWest1 
                                                                                  andTable:@"saturnde_ad93b7fe4c_channel"];
    [request startRequestWithDelegate:self];
    
    self.isDone = NO;
     NSDate *untilDate;
    while(!self.isDone){
        untilDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        [[NSRunLoop currentRunLoop] runUntilDate:untilDate];
    }
    XCTAssertNotNil(self.configs);
    XCTAssertEqual([self.configs count], 1);

}
-(void)testAWSConfigCancel{
    TARTTChannelConfigRequest *request = [[TARTTChannelConfigRequest alloc] initWithPoolID:@"eu-west-1:99e5483a-51cf-4c6f-a8d3-b7a5cee36b98" 
                                                                                 andRegion:AWSRegionEUWest1 
                                                                                  andTable:@"saturnde_ad93b7fe4c_channel"];
    [request startRequestWithDelegate:self];
    [request cancel];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.5]];
    XCTAssertNil(self.configs);
}
-(void)finishedConfigRequestWithSuccess:(NSArray *)configs{
    self.configs = configs;
    self.isDone = YES;
}
-(void)finishedConfigRequestWithError:(NSError *)error{
    self.isDone = YES;    
}
@end