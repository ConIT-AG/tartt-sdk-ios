//
//  TARTTChannel.h
//  Pods
//
//
//  Model Class

#import <Foundation/Foundation.h>
#import "TARTTConfig.h"



/*!
 @class TARTTChannel
 
 @abstract Model Class of a Channel which holdes the paths needed
 */
@interface TARTTChannel : NSObject

/*! the main path where all the channel files are stored */
@property (nonatomic, strong) NSString *mainPath;

/*! the uuid based sub directory of the latest channel */
@property (nonatomic, strong) NSString *currentPath;

/*! the path of the channel before the current one. Is used for copying files to the new directory */
@property (nonatomic, strong) NSString *lastPath;

/*! the temporary path where all downloads are saved before moved to the current path */
@property (nonatomic, strong) NSString *tempPath;

/*! configuration of this channel which holdes all file locations */
@property (nonatomic, strong) TARTTConfig *config;

@end