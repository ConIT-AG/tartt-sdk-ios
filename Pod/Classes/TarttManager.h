//
//  TarttManager.h
//  Pods
//
//  Created by Thomas Opiolka on 05.10.15.
//
//

#import <Foundation/Foundation.h>


@interface TarttManager : NSObject

+(instancetype)sharedManager;
-(void) startManager;
-(void) stopManager;


@end
