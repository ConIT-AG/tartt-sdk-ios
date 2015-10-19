//
//  ChannelManagerTests.m
//  TARTT
//
//  Created by Thomas Opiolka on 15.10.15.
//  Copyright © 2015 wh33ler. All rights reserved.
//

#import "Kiwi.h"
#import "Tartt.h"

SPEC_BEGIN(ChannelManager)

describe(@"ChannelManager", ^{
    TARTTChannelManager *manager = [TARTTChannelManager defaultManager];
   
    context(@"with Config", ^{
        let(config, ^{ 
            TARTTConfig *config = [TARTTConfig new];
            config.channelKey = @"ChannelKey1";
            return config;
        });
        let(cacheDir,^{
            return [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/"];
        });
        beforeAll(^{
             [[NSFileManager defaultManager] removeItemAtPath:[cacheDir stringByAppendingString:@"TARTT/Channels/"] error:nil];
        });
        
        it(@"should build som directories", ^{
            NSFileManager *filemanagerMock = [NSFileManager nullMock];
            [[NSFileManager should] receive:@selector(defaultManager) andReturn:filemanagerMock withCountAtLeast:1];
            [[filemanagerMock should] receive:@selector(createDirectoryAtPath:withIntermediateDirectories:attributes:error:) withCountAtLeast:4];          
            NSError *error;           
            [manager prepareChannelWithConfig:config error:&error];            
        });
    });
});

SPEC_END