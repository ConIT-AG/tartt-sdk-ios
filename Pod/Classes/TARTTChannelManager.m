//
//  TARTTChannelManager.m
//  Pods
//
//  Created by Thomas Opiolka on 07.10.15.
//
//

#import "TARTTChannelManager.h"
#import "TARTTChannel.h"
#import "TARTTChannelConfig.h"
#import "TARTTHelper.h"
#import "Debug.h"

#define kCHANNELBASEDIR @"TARTT/Channels"


@interface TARTTChannelManager ()

@property (nonatomic) NSString *cacheDirectory;
@property (nonatomic) NSArray *configs;

@end

@implementation TARTTChannelManager

-(instancetype)initWithConfig:(TARTTChannelConfig*) config{
    self = [super init];
    if (self) {
        self.cacheDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/"];
        self.configs = [NSArray arrayWithObject:config];
    }
    return self;
}
-(instancetype)initWithMultipleConfigs:(NSArray *) configs{
    self = [super init];
    if (self) {
        self.cacheDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/"];
        self.configs = configs;
    }
    return self;
}
-(TARTTChannel *)getChannelInstance{
    TARTTChannelConfig * first = [self.configs firstObject];
    return [self getChannelByKey:first.key];
}
-(TARTTChannel *)getChannelByKey:(NSString *)channelKey{
    for (TARTTChannelConfig *conf in self.configs) {
        if([conf.key isEqualToString:channelKey])
        {
            TARTTChannel *channel = [[TARTTChannel alloc] init]; 
            channel.mainPath = [self getChannelPath:conf.key];
            channel.currentPath = [self createNewChannelVersion:conf.key];
            channel.tempPath = [self getTempPath:conf.key];
            channel.lastPath = [TARTTHelper getLastPath:conf.key];
            channel.config = conf;
            return channel;
        }
    }
    return nil;
}

-(NSString *)getChannelPath:(NSString *)channelKey
{
    NSString *channelPath = [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",kCHANNELBASEDIR,channelKey]];    
    if([TARTTHelper ensureDirExists:channelPath])
        return channelPath;
    return nil; 
}

-(NSString *)getTempPath:(NSString *)channelKey
{
    NSString *temp = [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/temp",kCHANNELBASEDIR,channelKey]];
    if([TARTTHelper ensureDirExists:temp])
        return temp;
    return nil;
}
-(NSString *)createNewChannelVersion:(NSString *)channelKey{
    NSString *channelPath = [self getChannelPath:channelKey];
    NSString *newVersionPath = [channelPath stringByAppendingString:[[NSUUID UUID] UUIDString]];
    if([TARTTHelper ensureDirExists:newVersionPath])
        return newVersionPath;
    return nil;
}
-(BOOL)cleanUpChannel:(TARTTChannel *)channel{
    NSError *error;
    [[NSFileManager defaultManager]  removeItemAtPath:channel.tempPath error:&error];
    if(error != nil)
        DebugLog(@"error deleting temp directory %@",error);
    return error == nil;

}
-(BOOL)deleteChannel:(TARTTChannel *)channel{
    NSError *error;
    [[NSFileManager defaultManager]  removeItemAtPath:channel.mainPath error:&error];
    if(error != nil)
        DebugLog(@"error deleting Channel directory %@",error);
    return error == nil;
}
@end