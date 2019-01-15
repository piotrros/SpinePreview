//
//  STDevice.h
//  scgame-x
//
//  Created by Steve Tranby on 5/16/13.
//  Copyright (c) 2013 Steve Tranby. All rights reserved.
//
//  License: MIT
//

#ifndef __scgame_x__STDevice__
#define __scgame_x__STDevice__

#include <cocos/math/CCGeometry.h>
#include <cocos/base/CCValue.h>

typedef enum {
    kSTDeviceTypeIOS,
    kSTDeviceTypeAndroid,
    kSTDeviceTypeWP8,
    kSTDeviceTypeWinRT,
    kSTDeviceTypeMac,
    kSTDeviceTypeWin32,
    kSTDeviceTypeUnknown
} STDeviceType;

class STDeviceDelegate
{
public:
    virtual ~STDeviceDelegate() {};
    virtual void pickedFile(std::string filename) { CC_UNUSED_PARAM(filename); };
    virtual void checkForUpdates(int dummy) { CC_UNUSED_PARAM(dummy); };
};

class STDevice
{
public:
    virtual ~STDevice();
    static STDevice* getInstance();
    static void purgeInstance();

    virtual void setupMenu(cocos2d::GLViewImpl* glview, STDeviceDelegate* pDelegate) {}
    virtual void showFilePicker(STDeviceDelegate* pDelegate);
    virtual void openLink(const std::string& pUrl);

    CC_SYNTHESIZE(STDeviceType, _deviceType, DeviceType);
    CC_SYNTHESIZE(bool, _useHD, UseHD);
    CC_SYNTHESIZE(bool, _isHighMem, IsHighMem);
    CC_SYNTHESIZE(bool, _isHighPerfDevice, IsHighPerfDevice);

protected:
    STDevice();
    virtual bool init();
    static STDevice* s_sharedInstance;
    cocos2d::ApplicationProtocol* s_sharedApplication;
};

#endif /* defined(__scgame_x__STDevice__) */
