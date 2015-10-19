//
//  TARTTHelper.h
//  Pods
//
//
//

#import <Foundation/Foundation.h>

@interface TARTTHelper : NSObject


+(BOOL)ensureDirExists:(NSString *)path;
+(NSString *)getRelativePathOfItem:(NSDictionary *)item;
+(NSString *)getDummyChannelPath;
+(NSDictionary *)URLParameterFromURL:(NSURL *)URL;
+(NSString *)convertToJson:(NSDictionary *)dict;
@end
