//
//  TARTTHelper.m
//  Pods
//
//
//

#import "TARTTHelper.h"
#import "Debug.h"
#import "TARTTChannelManager.H"

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


+(NSString *)getRelativePathOfItem:(NSDictionary *)item
{
    return [[item objectForKey:@"dirname"] stringByAppendingPathComponent:[[item objectForKey:@"url"] lastPathComponent]];    
}
+(NSString *)getDummyChannelPath
{
    NSString *channelPath = [[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) firstObject] stringByAppendingString:@"/"] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@/%@",kCHANNELBASEDIR,@"Dummy"]];   
    
    if([TARTTHelper ensureDirExists:channelPath])
    {       
        [TARTTHelper copyFromBunde:@"index" withType:@"html" andDestination:[channelPath stringByAppendingString:@"/index.html"]];
        [TARTTHelper copyFromBunde:@"ade" withType:@"js" andDestination:[channelPath stringByAppendingString:@"/ade.js"]];
        [TARTTHelper copyFromBunde:@"qr" withType:@"js" andDestination:[channelPath stringByAppendingString:@"/qr.js"]];       
        [TARTTHelper copyFromBunde:@"project" withType:@"js" andDestination:[channelPath stringByAppendingString:@"/project.js"]];       
        return [channelPath stringByAppendingString:@"/index.html"];
    }
    return nil;
}
+(BOOL)copyFromBunde:(NSString *)name withType:(NSString *)type andDestination:(NSString *)destPath
{
    NSURL *bundleURL = [[NSBundle bundleForClass:[self class]] URLForResource:@"TARTT" withExtension:@"bundle"];
    NSBundle *bundle = [NSBundle bundleWithURL:bundleURL];
    NSString *bundlePath = [bundle pathForResource:name ofType:type];
    NSError *error;
    if([[NSFileManager defaultManager] fileExistsAtPath:destPath])
        [[NSFileManager defaultManager] removeItemAtPath:destPath error:&error];
    [[NSFileManager defaultManager] copyItemAtPath:bundlePath toPath:destPath error:&error];
    if(error) {
        DebugLog(@"Error %@",[error localizedDescription]);
        return NO;
    }       
    return YES;
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
+(NSString *)convertToJson:(NSDictionary *)dict
{
    NSError *error;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dict
                                                       options:0
                                                         error:&error];
    if (! jsonData)
    {
        DebugLog(@"Error in convertToJson %@",[error localizedDescription]);
        return @"{}";
    } else {
        return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
}
@end
