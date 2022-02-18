#pragma once

#include <raylib.h>
#include <LDtkLoader/World.hpp>

#include "../BaseScene.hpp"
#include "../Scenes.hpp"

#include "../../entities/Player.hpp"

class GameScene : public BaseScene
{
private:
    int current_level;
    Player *player;
    ldtk::World *ldtkWorld;
    const ldtk::Level *currentLdtkLevel;
    Texture2D renderedLevelTexture;

public:
    GameScene();
    ~GameScene();

    void draw() override;
    Scenes update(float dt) override;

    void set_selected_level();
};
