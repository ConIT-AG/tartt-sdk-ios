//
//  TARTTHelper.h
//  Pods
//
//
//

#import <Foundation/Foundation.h>

/*!
 @class TARTTHelper
 @abstract class with static helper methods 
 */
@interface TARTTHelper : NSObject



/*!
 @abstract look if a path exists. create it if not
 @param path the path in the local system
 @return true if it exists or could be created
 */
+(BOOL)ensureDirExists:(NSString *)path;

/*!
 @abstract build the path from a parse configuration file item
 @param item the dictionary holding the file url and directory infos
 @return the constructed path as string
 */
+(NSString *)getRelativePathOfItem:(NSDictionary *)item;

/*!
 @abstract creates a dummy AR-World in the local system.
 This is needed for showing the cam in the architectView 
 and for responding to QR-Code scanner events
 
 @return a path to the dummy AR-World
 */
+(NSString *)getDummyChannelPath;


/*!
 @abstract parse an url so the paratemters are returned as a dictionary
 @param URL the url that should be converted into a dic
 @return a dictionary which holds all keyvaluepairs
 */
+(NSDictionary *)URLParameterFromURL:(NSURL *)URL;

/*!
 @abstract convert a dictionary into a json string
 @param dict the dictionary to convert
 @return the converted json as a single line string
 */
+(NSString *)convertToJson:(NSDictionary *)dict;
@end
