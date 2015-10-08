//
//  TARTTHelper.m
//  Pods
//
//  Created by Thomas Opiolka on 08.10.15.
//
//

#import "TARTTHelper.h"
#import "Debug.h"

#define kCHANNELKEY @"TTARTChannelCurrentVersion"

@implementation TARTTHelper

+(BOOL)ensureDirExists:(NSString *)path
{
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];    
    if(![fileManager fileExistsAtPath:path]){
        [fileManager createDirectoryAtPath:path
               withIntermediateDirectories:YES
                                attributes:nil
                                     error:&error];
    }
    if(error != nil)
        DebugLog(@"error creating directory %@",error);
    return error == nil;
}

+(NSString *)getLastPath:(NSString *)channelKey
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *channelDictKey = [NSString stringWithFormat:@"%@-%@",channelKey,kCHANNELKEY];   
    return [defaults objectForKey:channelDictKey];
}
+(void)saveLastPath:(NSString *)lastPath forChannel:(NSString *)channelKey
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString *channelDictKey = [NSString stringWithFormat:@"%@-%@",channelKey,kCHANNELKEY];
    [defaults setObject:lastPath forKey:channelDictKey];
    [defaults synchronize];
}
+(NSString *)getRelativePathOfItem:(NSDictionary *)item
{
    return [[item objectForKey:@"dirname"] stringByAppendingPathComponent:[[item objectForKey:@"url"] lastPathComponent]];    
}
@end
