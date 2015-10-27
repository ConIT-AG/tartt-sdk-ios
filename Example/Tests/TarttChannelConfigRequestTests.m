//
//  TarttChannelConfigManagerTests.m
//  TARTT
//
//  Created by Thomas Opiolka on 08.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import <XCTest/XCTest.h>
#import <TARTT/TARTT.h>

#define kParseApplicationKey  @"iFGXKDe3ty3HKhmoAiWG7j2L6xm79z0YYz6ytIWo"
#define kParseClientKey @"k9J9eSSQuDus0bzORM0NA2glNn4FFmvY4XHyj9IC"

@interface TarttChannelConfigRequestTests : XCTestCase<TARTTChannelConfigRequestDelegate>
@property (nonatomic) BOOL isDone;
@property (nonatomic) BOOL isMulti;
@property (nonatomic) TARTTConfig *channel;
@property (nonatomic) NSError *error;
@end

@implementation TarttChannelConfigRequestTests

- (void)setUp {
    [super setUp];    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testParseMultipleConfigs 
{  
    self.isDone = NO;
    self.isMulti = NO;
    
    TARTTRequestOptions *options = [TARTTRequestOptions new];
    [options addLanguage:@"DE"];
    [options addEnvironment:TARTTEnvironmentProduction];
    [options addTargetApi:[NSNumber numberWithInt:3]];
    [options addTargetType:TARTTTargetTypeMainAndDetail];
    [options changeState:TARTTStateActive];
    
    TARTTChannelConfigRequest *request = [[TARTTChannelConfigRequest alloc] initWithApplicationID:kParseApplicationKey andClientKey:kParseClientKey andOptions:options];
    [request startRequestWithDelegate:self ignoreMultipleChannels:NO];    
   
     NSDate *untilDate;
    while(!self.isDone){
        untilDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        [[NSRunLoop currentRunLoop] runUntilDate:untilDate];
    }
    XCTAssertNil(self.channel);
    XCTAssertEqual(self.isMulti, YES);
}
-(void)testParseLatestConfigOfSetting
{
    self.isDone = NO;
    self.isMulti = NO;
    
    TARTTRequestOptions *options = [TARTTRequestOptions new];
    [options addLanguage:@"DE"];
    [options addEnvironment:TARTTEnvironmentProduction];
    [options addTargetApi:[NSNumber numberWithInt:3]];
    [options addTargetType:TARTTTargetTypeMainAndDetail];
    [options changeState:TARTTStateActive];
    
    TARTTChannelConfigRequest *request = [[TARTTChannelConfigRequest alloc] initWithApplicationID:kParseApplicationKey andClientKey:kParseClientKey andOptions:options];
    [request startRequestWithDelegate:self ignoreMultipleChannels:YES];    
    
    NSDate *untilDate;
    while(!self.isDone){
        untilDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        [[NSRunLoop currentRunLoop] runUntilDate:untilDate];
    }
    XCTAssertEqual(self.isMulti, NO);
    
    XCTAssertNotNil(self.channel);
    NSDictionary *content = [self.channel objectForKey:@"content"];
    XCTAssertNotNil(content);
    XCTAssertGreaterThan([[content objectForKey:@"files"] count], 2);


}


-(void)testParseConfigCancel
{
    TARTTRequestOptions *options = [TARTTRequestOptions new];
    [options addLanguage:@"de"];
    [options addEnvironment:TARTTEnvironmentProduction];
    [options addTargetApi:[NSNumber numberWithInt:3]];
    [options addTargetType:TARTTTargetTypeMainAndDetail];
    [options changeState:TARTTStateActive];

    TARTTChannelConfigRequest *request = [[TARTTChannelConfigRequest alloc] initWithApplicationID:kParseApplicationKey andClientKey:kParseClientKey andOptions:options];
    self.isDone = NO;
    self.isMulti = NO;
    [request startRequestWithDelegate:self ignoreMultipleChannels:NO];
    [request cancel];
    [[NSRunLoop currentRunLoop] runUntilDate:[NSDate dateWithTimeIntervalSinceNow:1.5]];
    XCTAssertNil(self.channel);
    XCTAssertEqual(self.isMulti, NO);
}

-(void)testParseConfigNoChannels{
    TARTTRequestOptions *options = [TARTTRequestOptions new];
    [options addLanguage:@"fr"];
    [options addEnvironment:TARTTEnvironmentTest];
    [options addTargetApi:[NSNumber numberWithInt:3]];
    [options addTargetType:TARTTTargetTypeMainAndDetail];
    [options changeState:TARTTStateActive];
    TARTTChannelConfigRequest *request = [[TARTTChannelConfigRequest alloc] initWithApplicationID:kParseApplicationKey andClientKey:kParseClientKey andOptions:options];
    [request startRequestWithDelegate:self ignoreMultipleChannels:NO];
    
    self.isDone = NO;
    NSDate *untilDate;
    while(!self.isDone){
        untilDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        [[NSRunLoop currentRunLoop] runUntilDate:untilDate];
    }    
    XCTAssertEqual(self.error.domain, TARTTErrorDomain);
    XCTAssertEqual(self.error.code, TARTTErrorNoChannelsAvailable);
}
-(void)testParseOptions
{ 
    
    TARTTRequestOptions *options = [TARTTRequestOptions new];
    [options addLanguage:@"de"];
    [options addEnvironment:TARTTEnvironmentTest];
    [options addTargetApi:[NSNumber numberWithInt:3]];
    [options addTargetType:TARTTTargetTypeMainAndDetail];
    [options changeState:TARTTStateActive];
    
    
    TARTTChannelConfigRequest *request = [[TARTTChannelConfigRequest alloc] initWithApplicationID:kParseApplicationKey 
                                                                                     andClientKey:kParseClientKey 
                                                                                       andOptions:options];  
   [request startRequestWithDelegate:self ignoreMultipleChannels:NO];
    
    self.isDone = NO;
    NSDate *untilDate;
    while(!self.isDone){
        untilDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        [[NSRunLoop currentRunLoop] runUntilDate:untilDate];
    }    
    XCTAssertNotNil(self.channel);
    NSDictionary *content = [self.channel objectForKey:@"content"];
    XCTAssertNotNil(content);
    XCTAssertGreaterThan([[content objectForKey:@"files"] count], 2);
}
-(void)testSelectChannel
{
    TARTTRequestOptions *options = [TARTTRequestOptions new];
    [options addLanguage:@"de"];
    [options addEnvironment:TARTTEnvironmentProduction];
    [options addTargetApi:[NSNumber numberWithInt:3]];
    [options addTargetType:TARTTTargetTypeMainAndDetail];
    [options changeState:TARTTStateActive];
    
    TARTTChannelConfigRequest *request = [[TARTTChannelConfigRequest alloc] initWithApplicationID:kParseApplicationKey andClientKey:kParseClientKey andOptions:options];
    self.isDone = NO;
    self.isMulti = NO;
    [request selectChannel:@"FlyerKw422" andDelegate:self];
    NSDate *untilDate;
    while(!self.isDone){
        untilDate = [NSDate dateWithTimeIntervalSinceNow:1.0];
        [[NSRunLoop currentRunLoop] runUntilDate:untilDate];
    }
    XCTAssertNotNil(self.channel);
    XCTAssertEqual(self.isMulti, NO);
}
-(void)finishedConfigRequestWithSuccess:(TARTTConfig *)config{
    self.isDone = YES;
    self.channel = config;
}
-(void)finishedConfigRequestWithError:(NSError *)error{
    self.isDone = YES;    
    self.error = error;
}
-(void)finishedConfigRequestWithMultipleChannels{
    self.isDone = YES;    
    self.isMulti = YES;
}
@end