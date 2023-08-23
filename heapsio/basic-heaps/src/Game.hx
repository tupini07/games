import scenes.UpdatableScene;

class Game extends hxd.App {
	public static var ME: Game;
	public var currentScene(default, set):UpdatableScene;

	function set_currentScene(s:UpdatableScene) {
		s2d = s;
		currentScene = s;

		s2d.setScale( dn.heaps.Scaler.bestFit_i(650,256) ); // scale view to fit

		return s;
	}

	static function main() {
		hxd.Res.initEmbed();
		hxd.Timer.wantedFPS = Constants.WANTED_FPS;

		ME = new Game();
	}

	override function init() {
		currentScene = new scenes.IntroScene();
	}

	override function update(dt:Float) {
		currentScene.update(dt);
	}
}
