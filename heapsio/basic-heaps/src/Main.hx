import managers.SceneManager;

class Main {
	static var sceneManager:SceneManager;

	static function main() {
		var p = new assets.LdtkData();
		// trace(p.all_levels); // Well done!

		sceneManager = new SceneManager();

		Love.update = function(dt:Float) {
			sceneManager.update(dt);

			Ctrl.clearJustPressedKeys();
		}

		Love.draw = function() {
			sceneManager.draw();
		}

		Love.keypressed = function(key, scancode, isrepeat) {
			Ctrl.registerKeypress(key);
		}

		trace("Hello, world!");
	}
}
