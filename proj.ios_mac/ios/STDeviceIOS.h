//
//  STDevice.h
//  scgame-x
//
//  Created by Steve Tranby on 6/16/13.
//  Copyright (c) 2013 Steve Tranby. All rights reserved.
//
//  License: MIT
//

#ifndef __scgame_x__STDeviceIOS__
#define __scgame_x__STDeviceIOS__

#include "STDevice.h"
#include <platform/CCPlatformMacros.h>


@interface STDeviceImplIOS : NSObject <UIAlertViewDelegate>
{
    void* _iosDelegate;
}

// Delegate used for testing call back into c++ land
@property(nonatomic, assign) void* iosDelegate;

@end


// MARK: -

class CC_DLL STDeviceIOS : public STDevice
{
public:
    virtual void openLink(const char* pUrl);
    virtual void showFilePicker(STDeviceDelegate* pDelegate);

    void addItemToArray(id item, cocos2d::ValueVector& pArray);
    void addNSValueToMap(id key, id value, cocos2d::ValueMap& pDict);
    void addValueToNSArray(const cocos2d::Value& object, NSMutableArray *array);
    void addValueToNSDict(const std::string& key, const cocos2d::Value& object, NSMutableDictionary *dict);

protected:
    STDeviceImplIOS* _impl;
};

#endif /* defined(__scgame_x__STDeviceIOS__) */
