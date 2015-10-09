//
//  TARTTHelper.m
//  Pods
//
//  Created by Thomas Opiolka on 08.10.15.
//
//

#import "TARTTHelper.h"
#import "Debug.h"
#import "TARTTChannelManager.H"

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
+(NSString *)getDummyChannelPath
{
    NSString *channelPath = [[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",kCHANNELBASEDIR,@"Dummy"]];   
    
    if([TARTTHelper ensureDirExists:channelPath]){
        NSString *defaultFile = [channelPath stringByAppendingString:@"/index.html"];
        NSString *html = @"<!DOCTYPE html PUBLIC \"-//W3C//DTD HTML 4.01 Transitional//EN\" \"http://www.w3.org/TR/html4/loose.dtd\"><html><head></head><body></body></html>";
        [[NSFileManager defaultManager] createFileAtPath:defaultFile contents:[html dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
        return defaultFile;
    }
    return nil;
}
+(NSDictionary *)URLParameterFromURL:(NSURL *)URL
{
    NSMutableDictionary *urlParameters = nil;
    NSString *urlString = [URL absoluteString];
    
    NSRange optionsRange = [urlString rangeOfString:@"?"];
    if (optionsRange.location != NSNotFound) {
        urlString = [urlString substringFromIndex:optionsRange.location+1 ];
        
        urlParameters = [NSMutableDictionary dictionary];
        NSArray *pairs = [urlString componentsSeparatedByString:@"&"];
        if (pairs.count > 0) {
            for (NSString *pair in pairs) {
                NSArray *componentPair = [pair componentsSeparatedByString:@"="];
                NSString *key = [[componentPair objectAtIndex:0] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                NSString *value = [[componentPair objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
                
                [urlParameters setObject:value forKey:key];
            }
        }
    }
    
    return urlParameters;
}

@end
