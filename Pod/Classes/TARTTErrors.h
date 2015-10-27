//
//  TARTTErrors.h
//  Pods
//
//
//

#import <Foundation/Foundation.h>


/* Tartt error domain */
FOUNDATION_EXPORT NSString *const TARTTErrorDomain;


/*!
 @typedef TARTTErrorType
 @abstract Tartt error types  
 */
typedef NS_ENUM(NSInteger, TARTTErrorType) {
    /* no channels available */
    TARTTErrorNoChannelsAvailable,
    /* thrown when at least one file couldn't be downloaded or moved */
    TARTTErrorDownloadIncomplete,
    /* error while trying to create, move or copy files/dirs */
    TARTTErrorCache,
    /* missing arguments in the parse config request */
    TARTTErrorMissingArguments,
    /* the channel that was selected could not be loaded */
    TARTTErrorCouldNotSelectChannel,
};