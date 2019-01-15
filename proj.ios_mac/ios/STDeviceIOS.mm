//
//  STDevice.cpp
//  scgame-x
//
//  Created by Steve Tranby on 6/16/13.
//  Copyright (c) 2013 Steve Tranby. All rights reserved.
//
//  License: MIT
//

#include "STDevice.h"
#include <platform/CCFileUtils.h>
#include "STDeviceIOS.h"

USING_NS_CC;

////////////////////////////////////////////////////////////////////////
// MARK: - OBJ Impl

@implementation STDeviceImplIOS

@synthesize iosDelegate = _iosDelegate;

- (void)showAlertWithDict:(NSDictionary*)dict
{
    UIAlertView *alert = [[[UIAlertView alloc] initWithTitle:dict[@"title"]
                                                     message:dict[@"desc"]
                                                    delegate:nil
                                           cancelButtonTitle:dict[@"cancelTitle"]
                                           otherButtonTitles:nil] autorelease];
    // optional - add more buttons:
    [alert setDelegate:self];
    [alert addButtonWithTitle:dict[@"okTitle"]];
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 1) {
        // call back into c++ code
        STDeviceDelegate* pDelegate = ((STDeviceDelegate*) _iosDelegate);
        if (pDelegate != NULL)
        {
            // calling back into c++
//            pDelegate->alertViewDidClose((int)buttonIndex);
        }
    }
}

@end



////////////////////////////////////////////////////////////////////////
// MARK: Singleton Instance -

STDevice* STDevice::getInstance()
{
    if (s_sharedInstance == nullptr)
    {
        s_sharedInstance = new STDeviceIOS();
        s_sharedInstance->init();
        s_sharedInstance->setDeviceType(STDeviceType::kSTDeviceTypeIOS);
    }
    return s_sharedInstance;
}

////////////////////////////////////////////////////////////////////////
// MARK: -

void STDeviceIOS::openLink(const char* pUrl)
{
    NSString* urlStr = [NSString stringWithUTF8String:pUrl];
    NSURL *url = [NSURL URLWithString:urlStr];
    [[UIApplication sharedApplication] openURL:url];
}

// method calling from c++ 
void STDeviceIOS::showFilePicker(STDeviceDelegate* pDelegate)
{
//    _impl = [[STDeviceImplIOS alloc] init];
//    _impl.iosDelegate = pDelegate;
//
//    NSDictionary* dict = @{
//                           @"title": @(title.c_str()),
//                           @"desc": @(desc.c_str()),
//                           @"okTitle": @(okTitle.c_str()),
//                           @"cancelTitle": @(cancelTitle.c_str())
//                           };
//    [_impl showAlertWithDict:dict];
}

////////////////////////////////////////////////////////////////////////
// MARK: -

void STDeviceIOS::addItemToArray(id item, ValueVector& pArray)
{
    // add string value into array
    if ([item isKindOfClass:[NSString class]]) {
        auto pValue = Value(std::string([item UTF8String]));
        pArray.push_back(Value(pValue));
        return;
    }

    // add number value into array(such as int, float, bool and so on)
    if ([item isKindOfClass:[NSNumber class]]) {
        NSString* pStr = [item stringValue];
        auto pValue = Value([pStr UTF8String]);
        pArray.push_back(Value(pValue));
        return;
    }

    // add dictionary value into array
    if ([item isKindOfClass:[NSDictionary class]]) {
        ValueMap pDictItem;
        for (id subKey in [item allKeys]) {
            id subValue = [item objectForKey:subKey];
            addNSValueToMap(subKey, subValue, pDictItem);
        }
        pArray.push_back(Value(pDictItem));
        return;
    }

    // add array value into array
    if ([item isKindOfClass:[NSArray class]]) {
        ValueVector pArrayItem;
        for (id subItem in item) {
            addItemToArray(subItem, pArrayItem);
        }
        pArray.push_back(Value(pArrayItem));
        return;
    }
}

void STDeviceIOS::addValueToNSArray(const Value& object, NSMutableArray *array)
{
    // add string into array
    if (object.getType() == Value::Type::STRING)
    {
        auto ccString = object.asString();
        NSString *strElement = [NSString stringWithCString:ccString.c_str() encoding:NSUTF8StringEncoding];
        [array addObject:strElement];
        return;
    }

    // the object is bool
    if (object.getType() == Value::Type::BOOLEAN)
    {
        auto element = object.asBool();
        NSNumber *strElement = [NSNumber numberWithBool:element];
        [array addObject:strElement];
        return;
    }

    // the object is float
    if (object.getType() == Value::Type::FLOAT)
    {
        auto element = object.asFloat();
        NSNumber *strElement = [NSNumber numberWithFloat:element];
        [array addObject:strElement];
        return;
    }

    // the object is double
    if (object.getType() == Value::Type::DOUBLE)
    {
        auto element = object.asDouble();
        NSNumber *strElement = [NSNumber numberWithDouble:element];
        [array addObject:strElement];
        return;
    }

    // the object is int
    if (object.getType() == Value::Type::INTEGER) {
        auto element = object.asInt();
        NSNumber *strElement = [NSNumber numberWithInt:element];
        [array addObject:strElement];
        NSLog(@"[arr] %d", element);
        return;
    }

    // add array into array
    if (object.getType() == Value::Type::VECTOR)
    {
        ValueVector ccArray = object.asValueVector();
        NSMutableArray *arrElement = [NSMutableArray array];
        for(auto& value : ccArray)
        {
            addValueToNSArray(value, arrElement);
        }
        [array addObject:arrElement];
        return;
    }

    // add dictionary value into array
    if (object.getType() == Value::Type::MAP)
    {
        ValueMap ccDict = object.asValueMap();
        NSMutableDictionary *dictElement = [NSMutableDictionary dictionary];
        for(auto& kv : ccDict)
        {
            addValueToNSDict(kv.first, kv.second, dictElement);
        }
        [array addObject:dictElement];
    }
}

void STDeviceIOS::addNSValueToMap(id key, id value, ValueMap& pDict)
{
    // the key must be a string
    CCAssert([key isKindOfClass:[NSString class]], "The key should be a string!");
    std::string pKey = [key UTF8String];

    // the value is a new dictionary
    if ([value isKindOfClass:[NSDictionary class]]) {
        ValueMap pSubDict;
        for (id subKey in [value allKeys]) {
            id subValue = [value objectForKey:subKey];
            addNSValueToMap(subKey, subValue, pSubDict);
        }
        pDict[pKey] = Value(pSubDict);
        return;
    }

    // the value is a string
    if ([value isKindOfClass:[NSString class]]) {
        auto pValue = Value(std::string([value UTF8String]));
        pDict[pKey] = pValue;
        return;
    }

    // the value is a number
    if ([value isKindOfClass:[NSNumber class]]) {
        NSString* pStr = [value stringValue];
        auto pValue = Value(std::string([pStr UTF8String]));
        pDict[pKey] = pValue;
        return;
    }

    // the value is a array
    if ([value isKindOfClass:[NSArray class]]) {
        ValueVector pArray;
        for (id item in value) {
            addItemToArray(item, pArray);
        }
        pDict[pKey.c_str()] = Value(pArray);
        return;
    }
}

void STDeviceIOS::addValueToNSDict(const std::string& key, const Value& object, NSMutableDictionary *dict)
{
    NSString *NSkey = [NSString stringWithCString:key.c_str() encoding:NSUTF8StringEncoding];

    // the object is a __Dictionary
    if (object.getType() == Value::Type::MAP)
    {
        ValueMap ccDict = object.asValueMap();
        NSMutableDictionary *dictElement = [NSMutableDictionary dictionary];
        for(auto& kv : ccDict)
        {
            addValueToNSDict(kv.first, kv.second, dictElement);
        }
        [dict setObject:dictElement forKey:NSkey];
        return;
    }

    // the object is a __String
    if (object.getType() == Value::Type::STRING)
    {
        auto ccString = object.asString();
        NSString *strElement = [NSString stringWithCString:ccString.c_str() encoding:NSUTF8StringEncoding];
        [dict setObject:strElement forKey:NSkey];
        return;
    }

    // the object is bool
    if (object.getType() == Value::Type::BOOLEAN)
    {
        auto element = object.asBool();
        NSNumber *strElement = [NSNumber numberWithBool:element];
        [dict setObject:strElement forKey:NSkey];
        return;
    }

    // the object is float
    if (object.getType() == Value::Type::FLOAT)
    {
        auto element = object.asFloat();
        NSNumber *strElement = [NSNumber numberWithFloat:element];
        [dict setObject:strElement forKey:NSkey];
        return;
    }

    // the object is double
    if (object.getType() == Value::Type::DOUBLE)
    {
        auto element = object.asDouble();
        NSNumber *strElement = [NSNumber numberWithDouble:element];
        [dict setObject:strElement forKey:NSkey];
        return;
    }

    // the object is int
    if (object.getType() == Value::Type::INTEGER) {
        auto element = object.asInt();
        NSNumber *strElement = [NSNumber numberWithInt:element];
        [dict setObject:strElement forKey:NSkey];
        NSLog(@"%@ = %d", NSkey, element);
        return;
    }

    // the object is a __Array
    if (object.getType() == Value::Type::VECTOR)
    {
        ValueVector ccArray = object.asValueVector();
        NSMutableArray *arrElement = [NSMutableArray array];
        for(auto& value : ccArray)
        {
            cocos2d::log("%s", value.getDescription().c_str());
            addValueToNSArray(value, arrElement);
        }
        [dict setObject:arrElement forKey:NSkey];
        return;
    }
}

