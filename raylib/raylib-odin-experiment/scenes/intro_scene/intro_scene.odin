package intro_scene

import "core:fmt"

import "../scene_constants"

init :: proc() {
	fmt.println("Hello from init intro!")
}

update :: proc(dt: f32) -> scene_constants.KnownScenes {
	fmt.println("Hello from update init!")

	return .GameScene
}