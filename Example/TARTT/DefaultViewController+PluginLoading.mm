//
//  WTAugmentedRealityViewController+PluginLoading.m
//  SDKExamples
//
//  Created by Andreas Schacherbauer on 27/07/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#import "DefaultViewController+PluginLoading.h"

#include <memory>
#import <objc/runtime.h>

#import <WikitudeSDK/WTArchitectView+Plugins.h>
#import "BarcodePlugin.h"

NSString * const kWTPluginIdentifier_BarcodePlugin = @"com.wikitude.plugin.barcode";


@implementation DefaultViewController (PluginLoading)

- (void)loadNamedPlugin:(NSString *)pluginName
{
    if ( [pluginName isEqualToString:kWTPluginIdentifier_BarcodePlugin] )
    {
    }    
}

- (void)startNamedPlugin:(NSString *)pluginName
{
    if ( [pluginName isEqualToString:kWTPluginIdentifier_BarcodePlugin] )
    {
        [self.architectView registerPlugin:std::make_shared<BarcodePlugin>([kWTPluginIdentifier_BarcodePlugin cStringUsingEncoding:NSUTF8StringEncoding], 640, 480)];
    }   
}

- (void)stopNamedPlugin:(NSString *)pluginName
{
    if ( [pluginName isEqualToString:kWTPluginIdentifier_BarcodePlugin] )
    {
        [self.architectView removeNamedPlugin:kWTPluginIdentifier_BarcodePlugin];
    }
}

@end
