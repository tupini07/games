package main

import rl "vendor:raylib"
import "core:fmt"

import "scenes"

import "scenes/intro_scene"
import "scenes/game_scene"

// odin build . -out:build/cart.wasm -target:freestanding_wasm32 -no-entry-point -extra-linker-flags:"--import-memory -zstack-size=14752 --initial-memory=65536 --max-memory=65536 --stack-first --lto-O3 --gc-sections --strip-all"


texture: rl.Texture2D

main :: proc() {
	scenes.set_scene(.IntroScene)

	fmt.println(">>> Raylib version is: ", rl.VERSION)

	rl.SetConfigFlags({rl.ConfigFlag.MSAA_4X_HINT, rl.ConfigFlag.VSYNC_HINT})
	rl.InitWindow(800, 800, "asdasd")
	defer rl.CloseWindow()

	rl.InitAudioDevice()
	defer rl.CloseAudioDevice()

	rl.SetTargetFPS(60)

	texture = rl.LoadTexture("assets/test.png")
	defer rl.UnloadTexture(texture)

	scenes.update()

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		defer rl.EndDrawing()

		rl.ClearBackground(rl.RAYWHITE)
		rl.DrawText("hey potato!", 190, 200, 20, rl.LIGHTGRAY)

		rl.DrawTexture(
			texture,
			rl.GetMouseX() - texture.width / 2,
			rl.GetMouseY() - texture.height / 2,
			rl.WHITE,
		)
	}
}
