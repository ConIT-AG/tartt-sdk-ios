//
//  TARTTChannelManager.m
//  Pods
//
//
//

#import "TARTTChannelManager.h"
#import "TARTTChannel.h"
#import "TARTTHelper.h"
#import "TARTTErrors.h"
#import "Debug.h"

#define kCHANNELKEY @"TTARTChannelCurrentVersion"

@interface TARTTChannelManager ()

@property (nonatomic) NSString *cacheDirectory;
@property (nonatomic) TARTTConfig *config;
@end

@implementation TARTTChannelManager

-(instancetype)init{
    self = [super init];
    if (self) {
        self.cacheDirectory = [[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/"];
    }
    return self;
}
-(TARTTChannel *)prepareChannelWithConfig:(TARTTConfig *)config error:(NSError **)error
{
    self.config = config;
    NSString *channelKey = self.config.channelKey;
    
    TARTTChannel *channel = [[TARTTChannel alloc] init]; 
    channel.mainPath = [self getChannelPath:channelKey error:error];
    channel.currentPath = [self createNewChannelVersion:channelKey error:error];
    channel.tempPath = [self getTempPath:channelKey error:error];
    channel.lastPath = [self getLastPath:channelKey];
    channel.config = self.config;
    return channel;
}

-(BOOL)cleanUpChannel:(TARTTChannel *)channel error:(NSError **)error{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if([filemanager fileExistsAtPath:channel.tempPath])
    {
        [filemanager  removeItemAtPath:channel.tempPath error:error];
        if(*error != nil)
            return NO;
    }
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
                [filemanager removeItemAtPath:file error:error];
                if(*error != nil)
                    DebugLog(@"error deleting old version directory %@",*error);
                
            }
        }
    }   
    return error == nil;
    
}
-(BOOL)deleteChannel:(TARTTChannel *)channel error:(NSError **)error{
    NSFileManager *filemanager = [NSFileManager defaultManager];
    if([filemanager fileExistsAtPath:channel.mainPath])
        [filemanager  removeItemAtPath:channel.mainPath error:error];
    return *error == nil;
}
-(void)saveLastPath:(NSString *)lastPath forChannel:(NSString *)channelKey
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *channelDictKey = [NSString stringWithFormat:@"%@-%@",channelKey,kCHANNELKEY];
    [defaults setObject:lastPath forKey:channelDictKey];
    [defaults synchronize];
}

#pragma mark singleton
+ (TARTTChannelManager *)defaultManager
{
    static TARTTChannelManager *sharedManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedManager = [[self alloc] init];
    });
    return sharedManager;   
}

#pragma mark private methods
-(NSString *)getLastPath:(NSString *)channelKey
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *channelDictKey = [NSString stringWithFormat:@"%@-%@",channelKey,kCHANNELKEY];   
    return [defaults objectForKey:channelDictKey];
}
-(NSString *)getChannelPath:(NSString *)channelKey error:(NSError **)error
{
    NSString *channelPath = [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",kCHANNELBASEDIR,channelKey]];    
    if([TARTTHelper ensureDirExists:channelPath])
        return channelPath;
    if (error) {
        *error = [NSError errorWithDomain:TARTTErrorDomain
                                     code:TARTTErrorCache
                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Coudl not create channel path: %@",channelPath]}];
    }        
    return nil; 
}

-(NSString *)getTempPath:(NSString *)channelKey error:(NSError **)error
{
    NSString *temp = [self.cacheDirectory stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@/temp",kCHANNELBASEDIR,channelKey]];
    if([TARTTHelper ensureDirExists:temp])
        return temp;
    if (error) {
        *error = [NSError errorWithDomain:TARTTErrorDomain
                                     code:TARTTErrorCache
                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Coudl not create temp path: %@",temp]}];
    }  
    return nil;
}
-(NSString *)createNewChannelVersion:(NSString *)channelKey error:(NSError **)error
{
    NSString *channelPath = [[self getChannelPath:channelKey error:error] stringByAppendingString:@"/"];
    NSString *newVersionPath = [channelPath stringByAppendingString:[[NSUUID UUID] UUIDString]];
    if([TARTTHelper ensureDirExists:newVersionPath])
        return newVersionPath;
    if (error) {
        *error = [NSError errorWithDomain:TARTTErrorDomain
                                     code:TARTTErrorCache
                                 userInfo:@{NSLocalizedDescriptionKey: [NSString stringWithFormat:@"Coudl not create path for new channel version: %@",newVersionPath]}];
    }  
    return nil;
}

@end