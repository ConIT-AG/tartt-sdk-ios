//
//  TARTTHelper.h
//  Pods
//
//  Created by Thomas Opiolka on 08.10.15.
//
//

#import <Foundation/Foundation.h>

@interface TARTTHelper : NSObject


+(BOOL)ensureDirExists:(NSString *)path;
+(NSString *)getLastPath:(NSString *)channelKey;
+(void)saveLastPath:(NSString *)lastPath forChannel:(NSString *)channelKey;
+(NSString *)getRelativePathOfItem:(NSDictionary *)item;
@end
