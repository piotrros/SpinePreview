#ifndef __MAIN_SCENE_H__
#define __MAIN_SCENE_H__

#include "cocos2d.h"
#include <spine/spine-cocos2dx.h>
#include "cocostudio/CocoStudio.h"
#include "ui/CocosGUI.h"
#include "STDevice.h"

USING_NS_CC;
using namespace std;
using namespace spine;
using namespace cocos2d::ui;

class MainScene : public cocos2d::Layer, public STDeviceDelegate
{
public:
    // there's no 'id' in cpp, so we recommend returning the class instance pointer
    static cocos2d::Scene* createScene();

    // Here's a difference. Method 'init' in cocos2d-x returns bool, instead of returning 'id' in cocos2d-iphone
    virtual bool init();

    // implement the "static create()" method manually
    CREATE_FUNC(MainScene);
    
    void loadSkeleton();
    void updateScale();
    void updateTimeScale();
    
    void pickedFile(string filename);
    
    Node* root;
    Node* skeletonLayer;
    ui::Text* txtCurrentFile;
    ui::Text* txtDimensions;
    ui::Text* txtScale;
    ui::Text* txtTimeScale;
    ui::Button* btnLoadModel;
    ui::Button* btnAddMixes;
    ui::Button* btnDrag;
    ui::Button* btnReset;
    ui::Button* btnFlipX;
    ui::Button* btnFlipY;
    ui::Button* btnBones;
    ui::Button* btnSlots;
    ui::ListView* lvSkins;
    ui::ListView* lvAnimations;
    ui::ListView* lvBones;
    ui::ListView* lvSlots;
    ui::Slider* sldScale;
    ui::Slider* sldTimeScale;
    DrawNode* anchorLines;
    
    string path;
    SkeletonAnimation* skeleton;
    vector<string> skins;
    vector<string> animations;
    vector<string> bones;
    vector<string> slots;
    
    Vec2 lastDrag;
    int lastSkinIndex;
    int lastAnimIndex;
    
    cocos2d::Rect box;
};

std::string to_str(int t);
std::string to_str(float t);
void setMultipleMixes(SkeletonAnimation* anim, vector<string> names1, vector<string> names2, bool both = true, float time = 0.5f);
int sgn(float x);

#endif // __MAIN_SCENE_H__
