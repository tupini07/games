package managers;

import scenes.*;
import utils.Debug;

class SceneManager {
	public static var ME(default, null):SceneManager;

	var currentScene:IScene;

	public function new() {
		new TimerManager();
		new FxManager();

		this.init();
		ME = this;
	}

	public function switch_scene(new_scene:IScene) {
		this.currentScene.dispose();
		this.currentScene = new_scene;
	}

	public function init() {
		currentScene = new IntroScene();
	}

	public function update(dt:Float) {
		currentScene.update(dt);
		TimerManager.ME.update_timers();
	}

	public function draw() {
		currentScene.draw();

		#if debug
		Debug.draw();
		#end
	}
}
