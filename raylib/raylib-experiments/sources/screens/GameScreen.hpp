#pragma once

#include "BaseScreen.hpp"
#include "Screens.hpp"

#include "../entities/Player.hpp"

class GameScreen : public BaseScreen
{
private:
    Player *player;

public:
    GameScreen();
    ~GameScreen();

    void draw();
    Screens update(float dt);
};
