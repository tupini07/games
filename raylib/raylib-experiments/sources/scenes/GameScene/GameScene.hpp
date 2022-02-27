#pragma once

#include <box2d/box2d.h>
#include <raylib.h>
#include <LDtkLoader/World.hpp>

#include "../BaseScene.hpp"
#include "../Scenes.hpp"

#include "../../entities/Player.hpp"

class GameScene : public BaseScene
{
private:
    int current_level;

    ldtk::World *ldtkWorld{};
    const ldtk::Level *currentLdtkLevel{};

    Texture2D currentTilesetTexture;
    Texture2D renderedLevelTexture;

public:
    GameScene();
    ~GameScene();

    static b2World *world;
    static Player *player;

    void draw() override;
    Scenes update(float dt) override;

    void set_selected_level(int lvl);
};
