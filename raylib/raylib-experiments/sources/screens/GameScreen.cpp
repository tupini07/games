#include "GameScreen.hpp"
#include "Screens.hpp"

GameScreen::GameScreen()
{
    player = new Player();
}

GameScreen::~GameScreen()
{
    delete player;
}

void GameScreen::draw() {
    player->draw();
}

Screens GameScreen::update(float dt) {
    player->update(dt);
    
    return NONE;
}
