//
//  WTAugmentedRealityViewController+PluginLoading.h
//  SDKExamples
//
//  Created by Andreas Schacherbauer on 27/07/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#import "DefaultViewController.h"

extern NSString * const kWTPluginIdentifier_BarcodePlugin;

@interface DefaultViewController (PluginLoading)

- (void)loadNamedPlugin:(NSString *)pluginName;

- (void)startNamedPlugin:(NSString *)pluginName;
- (void)stopNamedPlugin:(NSString *)pluginName;

@end
