#include <string>
#include <iostream>

#include <raylib.h>

#include <Constants.hpp>
#include "TitleScene.hpp"
#include "../Scenes.hpp"

using namespace std;

void TitleScene::draw()
{
	ClearBackground(RAYWHITE);

	const int texture_x = AppConstants::ScreenWidth / 2 - texture.width / 2;
	const int texture_y = AppConstants::ScreenHeight / 2.5 - texture.height / 2;
	DrawTexture(texture, texture_x, texture_y, WHITE);

	const string text = "I would like some potatoes please! Thank you";
	const Vector2 text_size = MeasureTextEx(GetFontDefault(), text.c_str(), 20, 1);
	DrawText(text.c_str(), AppConstants::ScreenWidth / 2 - text_size.x / 2, texture_y + texture.height + text_size.y + 10, 20, BLACK);

	int mouseX = GetMouseX();
	int mouseY = GetMouseY();

	int rectSize = AppConstants::ScreenWidth / 20;
	DrawRectangle(mouseX - rectSize / 2, mouseY - rectSize / 2, rectSize, rectSize, DARKPURPLE);

	DrawLine(mouseX, 0, mouseX, AppConstants::ScreenHeight, SKYBLUE);
	DrawLine(0, mouseY, AppConstants::ScreenWidth, mouseY, GREEN);

	DrawText("press 'c' to play!", 10, 10, 50, BLACK);
}

Scenes TitleScene::update(float dt)
{
	if (IsKeyPressed(KEY_C))
	{
		return Scenes::GAME;
	}

	return Scenes::NONE;
}

TitleScene::TitleScene()
{
	texture = LoadTexture(AppConstants::GetAssetPath("test.png").c_str());
}

TitleScene::~TitleScene()
{
}