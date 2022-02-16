#include "raylib.h"

#include "TitleScreen.hpp"
#include "ScreenManager.hpp"

void TitleScreen::draw()
{
    ClearBackground(RAYWHITE);
    DrawText("press 'c' to play!", 10, 10, 10, GREEN);
}

void TitleScreen::update(float dt)
{
    if (IsKeyPressed(KEY_C))
    {
        ScreenManager::set_current_screen(Screen::GAME);
    }
}

TitleScreen::TitleScreen()
{
}

TitleScreen::~TitleScreen()
{
}