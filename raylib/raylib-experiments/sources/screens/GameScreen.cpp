#include "GameScreen.hpp"

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

void GameScreen::update(float dt) {
    player->update(dt);
}
