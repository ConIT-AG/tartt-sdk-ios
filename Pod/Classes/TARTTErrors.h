//
//  TARTTErrors.h
//  Pods
//
//
//

#import <Foundation/Foundation.h>


FOUNDATION_EXPORT NSString *const TARTTErrorDomain;

typedef NS_ENUM(NSInteger, TARTTErrorType) {
    TARTTErrorNoChannelsAvailable,
    TARTTErrorDownloadIncomplete,
    TARTTErrorCache,
};