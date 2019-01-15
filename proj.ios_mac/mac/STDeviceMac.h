//
//  STDevice.h
//  scgame-x
//
//  Created by Steve Tranby on 6/16/13.
//
//

#ifndef __scgame_x__STDeviceMac__
#define __scgame_x__STDeviceMac__

#include "STDevice.h"
#include <iostream>
#include <platform/CCPlatformMacros.h>

// simple ObjC class to receive menu action(s)
@interface STDeviceImplMac : NSObject
{
    void* _macDelegate;
}

// Delegate used to call back into c++ land
@property(nonatomic, assign) void* macDelegate;

@property (assign) IBOutlet NSMenu *macMainMenu;

// Actions called from NSMenu
- (IBAction)checkForUpdates:(id)sender;
- (IBAction)menuAction:(id)sender;

@end


// MARK: -

/// Mac-specific Utils
class CC_DLL STDeviceMac : public STDevice
{
public:
    // Example of calling into ObjC land and then returning through a delegate callback to C++ land
    virtual void showFilePicker(STDeviceDelegate* pDelegate);
    virtual void setupMenu(cocos2d::GLViewImpl* glview, STDeviceDelegate* pDelegate);

    // Convert from NS-containers and Value-containers
    void addItemToArray(id item, cocos2d::ValueVector& pArray);
    void addNSValueToMap(id key, id value, cocos2d::ValueMap& pDict);
    void addValueToNSArray(const cocos2d::Value& object, NSMutableArray *array);
    void addValueToNSDict(const std::string& key, const cocos2d::Value& object, NSMutableDictionary *dict);

protected:
    virtual bool init();

    // The ObjC instance portion of this class
    STDeviceImplMac* _deviceImpl;
};



#endif /* defined(__scgame_x__STDeviceIOS__) */
