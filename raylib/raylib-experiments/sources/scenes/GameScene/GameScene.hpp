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

    b2World *world{};
    Player *player{};

    Texture2D currentTilesetTexture;
    Texture2D renderedLevelTexture;

public:
    GameScene();
    ~GameScene();

    void draw() override;
    Scenes update(float dt) override;

    void set_selected_level(int lvl);
};
