package game_scene

import "core:fmt"

import "../scene_constants"

init :: proc() {
	fmt.println("Hello from init game!")
}

update :: proc(dt: f32) -> scene_constants.KnownScenes {
	fmt.println("Hello from update game!")

	return .GameScene
}