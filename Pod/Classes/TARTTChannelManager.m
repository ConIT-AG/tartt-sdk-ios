//
//  TARTTChannelManager.m
//  Pods
//
//  Created by Thomas Opiolka on 07.10.15.
//
//

#import "TARTTChannelManager.h"
#import "TARTTChannel.h"
#import "TARTTHelper.h"
#import "Debug.h"

@interface TARTTChannelManager ()

@property (nonatomic) NSString *cacheDirectory;
@property (nonatomic) TARTTConfig *config;

@end

@implementation TARTTChannelManager

-(instancetype)initWithConfig:(TARTTConfig*) config{
    self = [super init];
    if (self) {
        self.cacheDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/"];
        self.config = config;
    }
    return self;
}
-(TARTTChannel *)getChannelInstance{
    NSString *channelKey = self.config.channelKey;
    TARTTChannel *channel = [[TARTTChannel alloc] init]; 
    channel.mainPath = [self getChannelPath:channelKey];
    channel.currentPath = [self createNewChannelVersion:channelKey];
    channel.tempPath = [self getTempPath:channelKey];
    channel.lastPath = [TARTTHelper getLastPath:channelKey];
    channel.config = self.config;
    return channel;
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
    NSString *channelPath = [[self getChannelPath:channelKey] stringByAppendingString:@"/"];
    NSString *newVersionPath = [channelPath stringByAppendingString:[[NSUUID UUID] UUIDString]];
    if([TARTTHelper ensureDirExists:newVersionPath])
        return newVersionPath;
    return nil;
}
-(BOOL)cleanUpChannel:(TARTTChannel *)channel{
    NSError *error;
    NSFileManager *filemanager = [NSFileManager defaultManager];
    [filemanager  removeItemAtPath:channel.tempPath error:&error];
    if(error != nil)
        DebugLog(@"error deleting temp directory %@",error);
    NSDirectoryEnumerator *dirEnum = [filemanager enumeratorAtPath:channel.mainPath];    
    NSString *file;
    while ((file = [dirEnum nextObject])) 
    {
        BOOL isDir;
        file = [channel.mainPath stringByAppendingPathComponent:file];
        if ([[NSFileManager defaultManager] fileExistsAtPath:file
                                                 isDirectory:&isDir] && isDir)
        {
            [dirEnum skipDescendants];
            if(![file isEqualToString:channel.currentPath]){
                [filemanager removeItemAtPath:file error:&error];
                if(error != nil)
                    DebugLog(@"error deleting old version directory %@",error);

            }
        }
    }   
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