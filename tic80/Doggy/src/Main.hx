package;

import managers.SceneManager;

@:expose
class Main {
	static var sceneManager:SceneManager;

	static function main() {
		sceneManager = new SceneManager();
	}

	@:natice("TIC") @:keep
	static function TIC() {
		sceneManager.tic();
	}
}
