package entities;

import Process.UpdateBubble;
import scenes.GameScene;
import gui.Popup;

class Girl extends Entity {
	public static function add_to_map(mapx:Int, mapy:Int):Girl {
		var wx = mapx * 8;
		var wy = mapy * 8;

		mset(mapx, mapy, 0);

		var g = new Girl(Npc, wx, wy, 0, 0, 0, 0);
		new Popup(g, [
			#if debug
			"1", "2"
			#else
			"Oh Doggy! There you are!", "Something terrible has happened.", "After we came out to play, I fell asleep",
			"and when I woke up all our friends where gone!", "At least you're here.", "The tea is ready! I hear grandma calling",
			"Could you help me find them?", "I'll meet you at grandmas.",
			#end
		], function() {
			// only fire if we haven't already encountered entity
			return !GameScene.Encounters.Girl;
		}, function() {
			GameScene.Encounters.Girl = true;
		});
		return g;
	}

	override function draw() {
		var flip_x = 0;
		if (GameScene.Hero != null) {
			flip_x = this.pos.x - GameScene.Hero.pos.x < 0 ? 1 : 0;
		}

		Cam.spr(264, cast this.pos.x, cast this.pos.y, 1, flip_x, 0, 2, 3);
	}

	override function update(ub:UpdateBubble) {
		super.update(ub);
	}
}
