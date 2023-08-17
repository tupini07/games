package scenes;

import managers.CheckpointManager;
import entities.Doggy;
import managers.ConversationManager;
import gui.Hud;
import entities.decorations.GameVeil;

class GameScene implements IScene {
	public static var Hero:Doggy;
	public static var hud:Hud;
	public static final Encounters = {
		Girl: true,
		Cat: true,
		Bird: true,
		Granny: false,
	};

	public function new() {
		new CheckpointManager();
		WorldMap.init_map_entities();
		ConversationManager.get_instance();
		GameScene.hud = new Hud();

		new GameVeil();
	}

	public function update(dt:Float) {
		Process.update_all_processes();
		Cam.updateCamera();
	}

	public function draw() {
		cls(9);
		Cam.map(0, 0, C.MAP_TOTAL_CELLS_WIDTH, C.MAP_TOTAL_CELLS_HEIGHT);

		Process.draw_all_processes();
	}

	public function dispose() {
		Process.reset();
	}
}
