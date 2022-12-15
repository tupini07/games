package entities;

import Process.UpdateBubble;
import scenes.GameScene;
import gui.Popup;

class Cat extends Entity {
	var stretch_state = -1;
	var post_encounter_sprite = 292;

	var cat_relax_state = 0;
	var cat_relax_state_direction_up = true;

	public static function add_to_map(mapx:Int, mapy:Int):Cat {
		var wx = mapx * 8;
		var wy = mapy * 8;

		mset(mapx, mapy, 0);

		var cat = new Cat(Npc, wx, wy, 0, 0, 0, 0);
		new Popup(cat, [
			#if debug "cat1", "cat2" #else "Grr why do you bother me", "oh well, see you there. I'll just stay here and stretch a bit"
			#end
		], function() {
			// only fire if we haven't already encountered entity
			return !GameScene.Encounters.Cat;
		}, function() {
			GameScene.Encounters.Cat = true;
			cat.stretch_state = 0;
		});
		return cat;
	}

	override function draw() {
		var flip_x = 0;
		if (GameScene.Hero != null) {
			flip_x = this.pos.x - GameScene.Hero.pos.x < 0 ? 1 : 0;
		}

		if (!GameScene.Encounters.Cat) {
			Cam.spr(288 + this.cat_relax_state, cast this.pos.x, cast this.pos.y, 1, flip_x);
		} else {
			Cam.spr(this.post_encounter_sprite, cast this.pos.x, cast this.pos.y, 1, flip_x);
		}
	}

	override function update(ub:UpdateBubble) {
		super.update(ub);

		if (!GameScene.Encounters.Cat) {
			Timers.register_if_not_present('cat-update-relax-state', 10, function() {
				if (this.cat_relax_state >= 3) {
					this.cat_relax_state_direction_up = false;
				}

				if (this.cat_relax_state <= 0)
					this.cat_relax_state_direction_up = true;

				if (this.cat_relax_state_direction_up)
					this.cat_relax_state += 1;
				else
					this.cat_relax_state -= 1;
			});
		} else if (this.stretch_state != -1) {
			Timers.register_if_not_present('cat-update-stretch-state', 50, function() {
				if (this.stretch_state == 0)
					post_encounter_sprite = 292;

				if (this.stretch_state == 1 || this.stretch_state == 3)
					post_encounter_sprite = 295;

				if (this.stretch_state == 2)
					post_encounter_sprite = 294;

				if (this.stretch_state > 3) {
					this.stretch_state = -1;
				} else {
					this.stretch_state += 1;
				}
			});
		} else {
			Timers.register_if_not_present('cat-update-after-enc-state', 30, function() {
				if (this.post_encounter_sprite == 292)
					this.post_encounter_sprite = 293;
				else
					this.post_encounter_sprite = 292;
			});
		}
	}
}
