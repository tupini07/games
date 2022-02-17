#include <string>

#include "raylib.h"

#if defined(PLATFORM_WEB)
#include <emscripten/emscripten.h>
#endif

#include "./entities/Player.hpp"
#include "./screens/ScreenManager.hpp"
#include "./screens/Screens.hpp"

#define SCREEN_WIDTH (800)
#define SCREEN_HEIGHT (450)

#define WINDOW_TITLE "Window title"

using namespace std;

void UpdateDrawFrame();

static Texture2D texture;

int main()
{
	ScreenManager::initialize();
	ScreenManager::set_current_screen(Screens::TITLE);

	InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, WINDOW_TITLE);
	SetTargetFPS(60);

	texture = LoadTexture(ASSETS_PATH"test.png"); // Check README.md for how this works

#if defined(PLATFORM_WEB)
	emscripten_set_main_loop(UpdateDrawFrame, 0, 1);
#else
	SetTargetFPS(60); // Set our game to run at 60 frames-per-second
	//--------------------------------------------------------------------------------------

	// Main game loop
	while (!WindowShouldClose()) // Detect window close button or ESC key
	{
		UpdateDrawFrame();
	}
#endif

	CloseWindow();
	return 0;
}

void UpdateDrawFrame()
{
	float dt = GetFrameTime();
	ScreenManager::update(dt);

	BeginDrawing();

	if (IsKeyDown(KEY_Q))
	{
		CloseWindow();
		return;
	}

	ScreenManager::draw();

	// const int texture_x = SCREEN_WIDTH / 2 - texture.width / 2;
	// const int texture_y = SCREEN_HEIGHT / 2.5 - texture.height / 2;
	// DrawTexture(texture, texture_x, texture_y, WHITE);

	// const string text = "I would like some potatoes please! Thank you";
	// const Vector2 text_size = MeasureTextEx(GetFontDefault(), text.c_str(), 20, 1);
	// DrawText(text.c_str(), SCREEN_WIDTH / 2 - text_size.x / 2, texture_y + texture.height + text_size.y + 10, 20, BLACK);

	// int mouseX = GetMouseX();
	// int mouseY = GetMouseY();

	// int rectSize = SCREEN_WIDTH / 20;
	// DrawRectangle(mouseX - rectSize / 2, mouseY - rectSize / 2, rectSize, rectSize, DARKPURPLE);

	// DrawLine(mouseX, 0, mouseX, SCREEN_HEIGHT, SKYBLUE);
	// DrawLine(0, mouseY, SCREEN_WIDTH, mouseY, GREEN);

	EndDrawing();
}