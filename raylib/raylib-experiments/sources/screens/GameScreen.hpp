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

    void draw() override;
    Screens update(float dt) override;
};
