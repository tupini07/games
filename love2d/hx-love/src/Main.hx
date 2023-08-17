import managers.SceneManager;

class Main {
	static var sceneManager:SceneManager;

	static function main() {
		sceneManager = new SceneManager();

		Love.update = function(dt:Float) {
			sceneManager.update(dt);
		}

		Love.draw = function() {
			sceneManager.draw();
		}

		trace("Hello, world!");
	}
}
