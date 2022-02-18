#include <raylib.h>

#if defined(PLATFORM_WEB)
#include <emscripten/emscripten.h>
#endif
#include <Constants.hpp>

#include "entities/Player.hpp"
#include "scenes/SceneManager.hpp"
#include "scenes/Scenes.hpp"

void UpdateDrawFrame();

int main()
{
	InitWindow(
		AppConstants::ScreenWidth,
		AppConstants::ScreenHeight,
		AppConstants::WindowTitle.c_str());

	SceneManager::initialize();
	SceneManager::set_current_screen(Scenes::TITLE);

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
	SceneManager::update(dt);

	BeginDrawing();

	if (IsKeyDown(KEY_Q))
	{
		CloseWindow();
		return;
	}

	SceneManager::draw();

	EndDrawing();
}