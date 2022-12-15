package scenes;

import managers.SceneManager;

class IntroScene implements IScene {
	public function new() {}

	public function update() {
		if (btn(A)) {
			SceneManager.ME.switch_scene(new GameScene());
		}
	}

	public function draw() {
		cls(3);
		print('Press A to start', 20, 20);
	}

	public function dispose() {}
}
