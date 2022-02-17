#include "raylib.h"

#if defined(PLATFORM_WEB)
#include <emscripten/emscripten.h>
#endif

#include "entities/Player.hpp"
#include "screens/ScreenManager.hpp"
#include "screens/Screens.hpp"
#include "constants.cpp"

void UpdateDrawFrame();

int main()
{
	ScreenManager::initialize();
	ScreenManager::set_current_screen(Screens::TITLE);

	InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, WINDOW_TITLE);
	SetTargetFPS(60);

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

	EndDrawing();
}