#include "MainScene.h"

Scene* MainScene::createScene()
{
    // 'scene' is an autorelease object
    auto scene = Scene::create();
    
    // 'layer' is an autorelease object
    auto layer = MainScene::create();

    // add layer as a child to scene
    scene->addChild(layer);

    // return the scene
    return scene;
}

// on "init" you need to initialize your instance
bool MainScene::init()
{
    
    //////////////////////////////
    // 1. super init first
    if ( !Layer::init() )
    {
        return false;
    }
    
    path = "";
    
    root = CSLoader::createNode("MainScene.csb");
    
    skeletonLayer = root->getChildByName("skeletonLayer");
    txtCurrentFile = root->getChildByName<ui::Text* >("txtCurrentFile");
    txtDimensions = root->getChildByName<ui::Text* >("txtDimensions");
    txtScale = root->getChildByName<ui::Text* >("txtScale");
    txtTimeScale = root->getChildByName<ui::Text* >("txtTimeScale");
    btnLoadModel = root->getChildByName<ui::Button* >("btnLoadModel");
    btnAddMixes = root->getChildByName<ui::Button* >("btnAddMixes");
    btnDrag = root->getChildByName<ui::Button* >("btnDrag");
    btnReset = root->getChildByName<ui::Button* >("btnReset");
    btnFlipX = root->getChildByName<ui::Button* >("btnFlipX");
    btnFlipY = root->getChildByName<ui::Button* >("btnFlipY");
    btnBones = root->getChildByName<ui::Button* >("btnBones");
    btnSlots = root->getChildByName<ui::Button* >("btnSlots");
    lvSkins = root->getChildByName<ui::ListView* >("lvSkins");
    lvAnimations = root->getChildByName<ui::ListView* >("lvAnimations");
    lvBones = root->getChildByName<ui::ListView* >("lvBones");
    lvSlots = root->getChildByName<ui::ListView* >("lvSlots");
    sldScale = root->getChildByName<ui::Slider* >("sldScale");
    sldScale->addEventListener([&](Ref* ref,ui::Slider::EventType eventType){
        if(eventType == ui::Slider::EventType::ON_PERCENTAGE_CHANGED){
            updateScale();
        }
    });
    sldTimeScale = root->getChildByName<ui::Slider* >("sldTimeScale");
    sldTimeScale->addEventListener([&](Ref* ref,ui::Slider::EventType eventType){
        if(eventType == ui::Slider::EventType::ON_PERCENTAGE_CHANGED){
            updateTimeScale();
        }
    });
    
    lvSkins->addEventListener([&](Ref* ref,ui::ListView::EventType eventType){
        if(eventType == ui::ListView::EventType::ON_SELECTED_ITEM_END){
            int index = lvSkins->getCurSelectedIndex();
            string skin = skins.at(index);
            
            if(lastSkinIndex != -1){
                auto oldItem = static_cast<ui::Button* >(lvSkins->getItem(lastSkinIndex));
                oldItem->setColor(Color3B::WHITE);
            }
            auto item = static_cast<ui::Button* >(lvSkins->getItem(index));
            item->setColor(Color3B::RED);
            lastSkinIndex = index;
            
            skeleton->setSkin(skin);
        }
    });
    
    lvAnimations->addEventListener([&](Ref* ref,ui::ListView::EventType eventType){
        if(eventType == ui::ListView::EventType::ON_SELECTED_ITEM_END){
            int index = lvAnimations->getCurSelectedIndex();
            string animation = animations.at(index);
            
            if(lastAnimIndex != -1){
                auto oldItem = static_cast<ui::Button* >(lvAnimations->getItem(lastAnimIndex));
                oldItem->setColor(Color3B::WHITE);
            }
            auto item = static_cast<ui::Button* >(lvAnimations->getItem(index));
            item->setColor(Color3B::RED);
            lastAnimIndex = index;
            
            skeleton->setAnimation(0, animation, true);
        }
    });
    
    btnLoadModel->addTouchEventListener([&](Ref* ref,Widget::TouchEventType eventType){
        if(eventType != ui::Widget::TouchEventType::ENDED) return;
        STDevice::getInstance()->showFilePicker(this);
    });
    
    btnAddMixes->addTouchEventListener([&](Ref* ref,Widget::TouchEventType eventType){
        if(eventType != ui::Widget::TouchEventType::ENDED) return;
        setMultipleMixes(skeleton, animations, animations);
        btnAddMixes->setVisible(false);
    });
    
    btnReset->addTouchEventListener([&](Ref* ref,Widget::TouchEventType eventType){
        if(eventType != ui::Widget::TouchEventType::ENDED) return;
        loadSkeleton();
    });
    
    skeleton = nullptr;
    anchorLines = DrawNode::create();
    anchorLines->drawLine(Vec2(-960 * 2, 320), Vec2(960 * 2, 320), Color4F::WHITE);
    anchorLines->drawLine(Vec2(480, -640 * 2), Vec2(480, 640 * 2), Color4F::WHITE);
    
    skeletonLayer->addChild(anchorLines);
    
    btnDrag->addTouchEventListener([&](Ref* ref,Widget::TouchEventType eventType){
        if(eventType == ui::Widget::TouchEventType::BEGAN){
            lastDrag = btnDrag->getTouchBeganPosition();
        }
        if(eventType == ui::Widget::TouchEventType::MOVED){
            Vec2 delta = btnDrag->getTouchMovePosition() - lastDrag;
            btnDrag->setPosition(btnDrag->getPosition() + delta);
            anchorLines->setPosition(anchorLines->getPosition() + delta);
            skeleton->setPosition(skeleton->getPosition() + delta);
            lastDrag = btnDrag->getTouchMovePosition();
        }
    });
    
    btnFlipX->addTouchEventListener([&](Ref* ref,Widget::TouchEventType eventType){
        if(eventType != ui::Widget::TouchEventType::ENDED) return;
        if(skeleton != nullptr){
            skeleton->setScaleX(-skeleton->getScaleX());
        }
    });
    
    btnFlipY->addTouchEventListener([&](Ref* ref,Widget::TouchEventType eventType){
        if(eventType != ui::Widget::TouchEventType::ENDED) return;
        if(skeleton != nullptr){
            skeleton->setScaleY(-skeleton->getScaleY());
        }
    });
    
    btnBones->addTouchEventListener([&](Ref* ref,Widget::TouchEventType eventType){
        if(eventType != ui::Widget::TouchEventType::ENDED) return;
        if(skeleton != nullptr){
            skeleton->setDebugBonesEnabled(!skeleton->getDebugBonesEnabled());
        }
    });
    
    btnSlots->addTouchEventListener([&](Ref* ref,Widget::TouchEventType eventType){
        if(eventType != ui::Widget::TouchEventType::ENDED) return;
        if(skeleton != nullptr){
            skeleton->setDebugSlotsEnabled(!skeleton->getDebugSlotsEnabled());
        }
    });
    
    STDevice::getInstance()->showFilePicker(this);
    
    addChild(root);

    return true;
}

void MainScene::updateScale(){
    float p = sldScale->getPercent() / 100.0f;
    skeleton->setScaleX(sgn(skeleton->getScaleX()) * p);
    skeleton->setScaleY(sgn(skeleton->getScaleY()) * p);
    txtScale->setString(to_str(sldScale->getPercent()) + "%");
    txtDimensions->setString("Size: " + to_str(box.size.width) + "x" + to_str(box.size.height) + " (" + to_str(box.size.width * p) + "x" + to_str(box.size.height * p) +  ")");
}

void MainScene::updateTimeScale(){
    float s = (sldTimeScale->getPercent() / 100.0f) * 5.0f;
    skeleton->setTimeScale(s);
    txtTimeScale->setString(to_str(s));
}

void MainScene::pickedFile(string filename){
    CCLOG("MainScene::pickedFile: %s", filename.c_str());
    path = filename;
    loadSkeleton();
}

void MainScene::loadSkeleton(){
    if(path == "") return;
    
    size_t lastindex = path.find_last_of(".");
    string atlasFilename = path.substr(0, lastindex) + ".atlas";
    string extension = path.substr(lastindex + 1, path.size());
    if(extension == "json"){
        if(skeleton != nullptr){
            skeleton->removeFromParent();
        }
        skeleton = SkeletonAnimation::createWithJsonFile(path, atlasFilename, 1.0f);
    }
    else if(extension == "skel"){
        if(skeleton != nullptr){
            skeleton->removeFromParent();
        }
        skeleton = SkeletonAnimation::createWithBinaryFile(path, atlasFilename, 1.0f);
    }
    else{
        CCLOG("unknown extension!");
        return;
    }
    
    lastSkinIndex = -1;
    lastAnimIndex = -1;
    
    skins.clear();
    animations.clear();
    bones.clear();
    slots.clear();
    
    btnAddMixes->setVisible(true);
    
    btnDrag->setPosition(Vec2(480, 320));
    anchorLines->setPosition(Vec2::ZERO);
    
    skeleton->setPosition(btnDrag->getPosition());
    skeleton->update(0.0f);
    skeleton->setEventListener([&](spTrackEntry* entry, spEvent* event) {
        log("%d event: %s, %d, %f, %s", entry->trackIndex, event->data->name, event->intValue, event->floatValue, event->stringValue);
        string n = event->data->name;
        ui::Text* txtEvent = ui::Text::create(n, "Arial", 24);
        txtEvent->runAction(Sequence::createWithTwoActions(Spawn::createWithTwoActions(MoveBy::create(1.0f, Vec2(0, 100)), FadeOut::create(1.0f)), RemoveSelf::create()));
        skeleton->addChild(txtEvent);
    });
    
    box = skeleton->getBoundingBox();
    
    for(int i = lvSkins->getItems().size() - 1; i >= 0; i--){
        lvSkins->removeItem(i);
    }
    
    for(int i = 0; i < skeleton->getState()->data->skeletonData->skinsCount; i++){
        string skin = skeleton->getState()->data->skeletonData->skins[i]->name;
        skins.push_back(skin);
        
        auto btnSkin = ui::Button::create("guzik.png");
        btnSkin->setTitleText(skin);
        btnSkin->setTitleFontSize(16);
        lvSkins->pushBackCustomItem(btnSkin);
    }
    
    for(int i = lvAnimations->getItems().size() - 1; i >= 0; i--){
        lvAnimations->removeItem(i);
    }
    
    for(int i = 0; i < skeleton->getState()->data->skeletonData->animationsCount; i++){
        auto anim = skeleton->getState()->data->skeletonData->animations[i];
        string animation = anim->name;
        float duration = anim->duration;
        animations.push_back(animation);
        
        auto btnAnim = ui::Button::create("guzik.png");
        btnAnim->setTitleText(animation + " (" + to_str(duration) + "s)");
        btnAnim->setTitleFontSize(16);
        lvAnimations->pushBackCustomItem(btnAnim);
    }
    
    for(int i = lvBones->getItems().size() - 1; i >= 0; i--){
        lvBones->removeItem(i);
    }
    
    for(int i = 0; i < skeleton->getState()->data->skeletonData->bonesCount; i++){
        auto bone = skeleton->getState()->data->skeletonData->bones[i];
        string name = bone->name;
        float length = bone->length;
        bones.push_back(name);
        
        auto btnBone = ui::Button::create("guzik.png");
        btnBone->setTitleText(name + " (len: " + to_str(length) + ")");
        btnBone->setTitleFontSize(16);
        lvBones->pushBackCustomItem(btnBone);
    }
    
    for(int i = lvSlots->getItems().size() - 1; i >= 0; i--){
        lvSlots->removeItem(i);
    }
    
    for(int i = 0; i < skeleton->getState()->data->skeletonData->slotsCount; i++){
        auto slot = skeleton->getState()->data->skeletonData->slots[i];
        string name = slot->name;
        slots.push_back(name);
        
        auto btnSlot = ui::Button::create("guzik.png");
        btnSlot->setTitleText(name);
        btnSlot->setTitleFontSize(16);
        lvSlots->pushBackCustomItem(btnSlot);
    }
    
    skeletonLayer->addChild(skeleton);
    
    sldScale->setPercent(100);
    sldTimeScale->setPercent(20);
    
    txtCurrentFile->setString("Current file: " + path);
    
    updateScale();
    updateTimeScale();
}

std::string to_str(int t) {
    std::stringstream ss;
    ss << t;
    std::string str = ss.str();
    return str;
}

std::string to_str(float t) {
    std::stringstream ss;
    ss << t;
    std::string str = ss.str();
    return str;
}

void setMultipleMixes(SkeletonAnimation* anim, vector<string> names1, vector<string> names2, bool both, float time){
    for(int j = 0; j < names2.size(); j++){
        for(int k = 0; k < names1.size(); k++){
            string n1 = names1.at(k);
            string n2 = names2.at(j);
            anim->setMix(n1, n2, time);
            if(both) anim->setMix(n2, n1, time);
        }
    }
}

int sgn(float x){
    if(x < 0) return -1;
    return 1;
}
