#pragma once

#include <LDtkLoader/World.hpp>

#include "BaseScreen.hpp"
#include "Screens.hpp"

#include "../entities/Player.hpp"

class GameScreen : public BaseScreen
{
private:
    int current_level;
    Player *player;
    ldtk::World *ldtkWorld;
    const ldtk::Level *currentLdtkLevel;

public:
    GameScreen();
    ~GameScreen();

    void draw() override;
    Screens update(float dt) override;
};
