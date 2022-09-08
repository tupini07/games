package scenes

import rl "vendor:raylib"

import sc "scene_constants"

import "game_scene"
import "intro_scene"

@(private)
current_intro: proc()

@(private)
current_update: proc(dt: f32) -> sc.KnownScenes

set_scene :: proc(new_scene: sc.KnownScenes) {
	switch new_scene {
	case .GameScene:
		current_intro = game_scene.init
        current_update = game_scene.update
	case .IntroScene:
		current_intro = intro_scene.init
        current_update = intro_scene.update
	}
}

update :: proc() {
	dt := rl.GetFrameTime()
	current_update(dt)
}
