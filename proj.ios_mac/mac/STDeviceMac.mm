//
//  STDevice.cpp
//  scgame-x
//
//  Created by Steve Tranby on 6/16/13.
//
//

#include "STDevice.h"
#include "STDeviceMac.h"

#include <platform/CCFileUtils.h>
#include <glfw3.h>

USING_NS_CC;

// MARK: -

@implementation STDeviceImplMac

@synthesize macDelegate = _macDelegate;

- (IBAction)checkForUpdates:(id)sender
{
    NSLog(@"enter ...");

    // call back into c++ code
    STDeviceDelegate* pDelegate = ((STDeviceDelegate*) _macDelegate);
    if (pDelegate != NULL)
    {
        // calling back into c++
        pDelegate->checkForUpdates(42);
    }
}

- (IBAction)menuAction:(id)sender
{
    NSLog(@"menu clicked");

    NSUInteger mask = NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask;
    NSRect winrect = {{100,100},{600,600}};
    NSWindow* win = [[NSWindow alloc] initWithContentRect:winrect styleMask:mask backing:NSBackingStoreBuffered defer:NO];
    [NSApp addWindowsItem:win title:@"Debug Title" filename:NO];
    [win setTitle:@"Steve Debug"];
    [[NSApp mainWindow] addChildWindow:win ordered:NSWindowAbove];
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    NSLog(@"woke up from nib, let's try to extract menu");
    [NSApp setMainMenu:self.macMainMenu];
}

@end


////////////////////////////////////////////////////////////////////////
// MARK: Singleton stuff -

STDevice* STDevice::getInstance()
{
    if (s_sharedInstance == nullptr)
    {
        s_sharedInstance = new STDeviceMac();
        s_sharedInstance->init();
        s_sharedInstance->setDeviceType(STDeviceType::kSTDeviceTypeMac);
    }
    return s_sharedInstance;
}

bool STDeviceMac::init()
{
    _deviceImpl = [[STDeviceImplMac alloc] init];
    return true;
}


void STDeviceMac::showFilePicker(STDeviceDelegate* pDelegate){
    NSArray *fileTypes = [NSArray arrayWithObjects:@"json", @"skel", nil];
    
    NSOpenPanel *panel = [NSOpenPanel openPanel];
    [panel setCanChooseFiles:YES];
    [panel setCanChooseDirectories:NO];
    [panel setAllowsMultipleSelection:NO]; // yes if more than one dir is allowed
    [panel setAllowedFileTypes:fileTypes];
    
    NSInteger clicked = [panel runModal];
    
    if (clicked == NSFileHandlingPanelOKButton) {
        for (NSURL *url in [panel URLs]) {
            NSString* nspath = url.path;
//            NSString* trimmednspath = [nspath stringByDeletingPathExtension];
//            std::string *path = new std::string([trimmednspath UTF8String]);
            std::string *path = new std::string([nspath UTF8String]);
            pDelegate->pickedFile(*path);
            break;
        }
    }
    
}

////////////////////////////////////////////////////////////////////////

void STDeviceMac::setupMenu(GLViewImpl* glview, STDeviceDelegate* pDelegate)
{
    _deviceImpl.macDelegate = (void*)pDelegate;

    // > 10.8
    id nibName = @"MainMenu";
    NSArray*    topLevelObjs = nil;
    [[NSBundle mainBundle] loadNibNamed:nibName owner:_deviceImpl topLevelObjects:&topLevelObjs];
    if ([topLevelObjs count] == 0)
    {
        NSLog(@"Warning! Could not load myNib file.\n");
        return;
    }

//    // < 10.7
//    [NSBundle loadNibNamed:nibName owner:_deviceImpl];

    NSWindow * appWindow = (NSWindow *)glfwGetCocoaWindow(glview->getWindow());
    if(appWindow)
    {
        // make your obj-c calls here
        NSMenu* menu = [NSApp windowsMenu];

        {
            NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:@"Check for Updates"
                                                              action:@selector(checkForUpdates:)
                                                       keyEquivalent:@""];
            [menuItem setTarget:_deviceImpl];
            [menu addItem:menuItem];
        }
        {
            NSMenuItem* menuItem = [[NSMenuItem alloc] initWithTitle:@"Test Menu Item"
                                                              action:@selector(menuAction:)
                                                       keyEquivalent:@""];
            [menuItem setTarget:_deviceImpl];
            [menu addItem:menuItem];
        }
    }
//
//    {
//        NSMenu* menu = [NSApp mainMenu];
//        if([menu numberOfItems] > 0) {
//            NSMenu* bar = [[NSMenu alloc] init];
//            [menu addItemWithTitle:@"Check for Updates" action:@selector(test) keyEquivalent:@""];
//            [NSApp setServicesMenu:bar];
//        }
//    }
}

//- (void) test:
//{
//}

/////////////////
// MARK: -

void STDeviceMac::addItemToArray(id item, ValueVector& pArray)
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

void STDeviceMac::addValueToNSArray(const Value& object, NSMutableArray *array)
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

void STDeviceMac::addNSValueToMap(id key, id value, ValueMap& pDict)
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

void STDeviceMac::addValueToNSDict(const std::string& key, const Value& object, NSMutableDictionary *dict)
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
