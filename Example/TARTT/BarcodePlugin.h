//
//  BarCodePlugin.h
//  DevApplication
//
//  Created by Andreas Schacherbauer on 15/05/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#ifndef __DevApplication__BarCodePlugin__
#define __DevApplication__BarCodePlugin__

#include "zbar.h"

#import <WikitudeSDK/Plugin.h>
#import <WikitudeSDK/Frame.h>
#import <WikitudeSDK/RecognizedTarget.h>


class BarcodePlugin : public wikitude::sdk::Plugin {
public:
    BarcodePlugin(const std::string& pluginIdentifier, int cameraFrameWidth, int cameraFrameHeight);
    virtual ~BarcodePlugin();

    virtual void initialize();
    virtual void destroy();

    virtual void cameraFrameAvailable(const wikitude::sdk::Frame& cameraFrame_);
    virtual void update(const std::list<wikitude::sdk::RecognizedTarget>& recognizedTargets_);

protected:
    int                             _worldNeedsUpdate;
    unsigned char*                  _imageData;

#ifndef SIMULATOR_BUILD
    zbar::Image                     _image;
    zbar::ImageScanner              _imageScanner;
#endif
};

#endif /* defined(__DevApplication__BarCodePlugin__) */
