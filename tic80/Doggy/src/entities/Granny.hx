package entities;

import entities.decorations.GameVeil;
import Process.UpdateBubble;
import scenes.GameScene;
import gui.Popup;

class Granny extends Entity {
	public static function add_to_map(mapx:Int, mapy:Int):Granny {
		var wx = mapx * 8;
		var wy = mapy * 8;

		mset(mapx, mapy, 0);

		var g = new Granny(Npc, wx, wy, 0, 0, 0, 0);
		new Popup(g, [
			#if debug
			"1", "2"
			#else
			"Welcome home Doggy! We were worried about you.",
			"Come in! We have hot chocolate.",
			#end
		], function() {
			// only fire if we haven't already encountered entity
			return !GameScene.Encounters.Granny;
		}, function() {
			GameScene.Encounters.Granny = true;
      GameVeil.ME.close_veil();
		});
		return g;
	}

	override function draw() {
		var flip_x = 0;
		if (GameScene.Hero != null) {
			flip_x = this.pos.x - GameScene.Hero.pos.x < 0 ? 1 : 0;
		}

		Cam.spr(266, cast this.pos.x, cast this.pos.y, 1, flip_x, 0, 2, 3);
	}

	override function update(ub:UpdateBubble) {
		super.update(ub);
	}
}
