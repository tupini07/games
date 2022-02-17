#include "raylib.h"

#include "TitleScreen.hpp"
#include "Screens.hpp"

void TitleScreen::draw()
{
    ClearBackground(RAYWHITE);
    DrawText("press 'c' to play!", 10, 10, 50, BLACK);
}

Screens TitleScreen::update(float dt)
{
    if (IsKeyPressed(KEY_C))
    {
        return Screens::GAME;
    }

    return Screens::NONE;
}

TitleScreen::TitleScreen()
{
}

TitleScreen::~TitleScreen()
{
}