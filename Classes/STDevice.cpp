//
//  STDevice.cpp
//  scgame-x
//
//  Created by Steve Tranby on 5/16/13.
//  Copyright (c) 2013 Steve Tranby. All rights reserved.
//
//  License: MIT
//

#include <platform/CCPlatformMacros.h>
#include "STDevice.h"

USING_NS_CC;

////////////////////////////////////////////////////////////////////////
// singleton stuff
STDevice* STDevice::s_sharedInstance = nullptr;

void STDevice::purgeInstance()
{
    CC_SAFE_DELETE(s_sharedInstance);
}

STDevice::STDevice()
: _deviceType(kSTDeviceTypeUnknown)
, _useHD(false)
, _isHighMem(true)
, _isHighPerfDevice(false)
{
}

STDevice::~STDevice() {}

bool STDevice::init()
{
    return true;
}

// MARK: -

void STDevice::showFilePicker(STDeviceDelegate* pDelegate)
{
    // Implement in platform-specific class
}

void STDevice::openLink(const std::string& pUrl)
{
    // not implemented
    CCLOG("NOT IMPLEMENTED");

    // Luckily cocos2d added this in 3.3 or 3.4
    // Jump to this method definition and you'll find platform specific code similar
    // to this, and probably a better example as well :]
    Application::getInstance()->openURL("http://cocos2d-x.org/");
}
