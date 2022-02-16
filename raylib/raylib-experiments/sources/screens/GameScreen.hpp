#pragma once

#include "BaseScreen.hpp"
#include "../entities/Player.hpp"

class GameScreen : public BaseScreen
{
private:
    Player *player;

public:
    GameScreen();
    ~GameScreen();

    void draw();
    void update(float dt);
};
