//
//  BarcodePlugin.cpp
//  DevApplication
//
//  Created by Andreas Schacherbauer on 15/05/15.
//  Copyright (c) 2015 Wikitude. All rights reserved.
//

#include "BarcodePlugin.h"

#include <iostream>
#include <sstream>


BarcodePlugin::BarcodePlugin(const std::string& pluginIdentifier, int cameraFrameWidth, int cameraFrameHeight)
:
Plugin(pluginIdentifier),
_worldNeedsUpdate(0)
#ifndef SIMULATOR_BUILD
,
_image(cameraFrameWidth, cameraFrameHeight, "Y800", nullptr, 0)
#endif
{
}

BarcodePlugin::~BarcodePlugin()
{
    /* Intentionally Left Blank */
}


void BarcodePlugin::initialize() {
#ifndef SIMULATOR_BUILD
    // DISABLE ALL MODES FIRST
    _imageScanner.set_config(zbar::ZBAR_NONE, zbar::ZBAR_CFG_ENABLE, 0);
    // ENABLE ONLY QR FOR PERFROMANCE
    _imageScanner.set_config(zbar::ZBAR_QRCODE, zbar::ZBAR_CFG_ENABLE, 1);
#endif
}

void BarcodePlugin::destroy() {
#ifndef SIMULATOR_BUILD
    _image.set_data(nullptr, 0);
#endif
}

void BarcodePlugin::cameraFrameAvailable(const wikitude::sdk::Frame& cameraFrame_) {
#ifndef SIMULATOR_BUILD
    int frameWidth = cameraFrame_.getSize().width;
    int frameHeight = cameraFrame_.getSize().height;
    
    _image.set_data(cameraFrame_.getLuminanceData(), frameWidth * frameHeight);
    int n = _imageScanner.scan(_image);

    if ( n != _worldNeedsUpdate ) {
        if ( n ) {
            std::ostringstream javaScript;
            javaScript << "performBarcodeRequest('";

            zbar::Image::SymbolIterator symbol = _image.symbol_begin();
            javaScript << symbol->get_data();

            javaScript << "');";
            
            addToJavaScriptQueue(javaScript.str());
        }
    }
    
    _worldNeedsUpdate = n;
#endif    
}

void BarcodePlugin::update(const std::list<wikitude::sdk::RecognizedTarget>& recognizedTargets_) {
    /* Intentionally Left Blank */
}
