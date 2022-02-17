#include <string>
#include "raylib.h"

#include "TitleScreen.hpp"
#include "Screens.hpp"
#include "../constants.cpp"

using namespace std;

void TitleScreen::draw()
{
    ClearBackground(RAYWHITE);

	const int texture_x = SCREEN_WIDTH / 2 - texture.width / 2;
	const int texture_y = SCREEN_HEIGHT / 2.5 - texture.height / 2;
	DrawTexture(texture, texture_x, texture_y, WHITE);

	const string text = "I would like some potatoes please! Thank you";
	const Vector2 text_size = MeasureTextEx(GetFontDefault(), text.c_str(), 20, 1);
	DrawText(text.c_str(), SCREEN_WIDTH / 2 - text_size.x / 2, texture_y + texture.height + text_size.y + 10, 20, BLACK);

	int mouseX = GetMouseX();
	int mouseY = GetMouseY();

	int rectSize = SCREEN_WIDTH / 20;
	DrawRectangle(mouseX - rectSize / 2, mouseY - rectSize / 2, rectSize, rectSize, DARKPURPLE);

	DrawLine(mouseX, 0, mouseX, SCREEN_HEIGHT, SKYBLUE);
	DrawLine(0, mouseY, SCREEN_WIDTH, mouseY, GREEN);

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
	texture = LoadTexture(ASSETS_PATH"test.png"); // Check README.md for how this works
}

TitleScreen::~TitleScreen()
{
}