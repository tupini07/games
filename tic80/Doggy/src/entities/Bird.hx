package entities;

import Process.UpdateBubble;
import scenes.GameScene;
import gui.Popup;

class Bird extends Entity {
	static inline final PRE_ANIM_SPEED = 30;
	static inline final POST_ANIM_SPEED = 40;

	var anim_frame_idx = 0;
	var finished_post_anim = false;
	var current_sprite = 304;

	final pre_encounter_animation = [304, 305, 304, 305, 304, 305, 306, 305];
	final post_encounter_animation = [305, 306, 307, 308, 307, 308, 307, 306];

	public static function add_to_map(mapx:Int, mapy:Int):Bird {
		var wx = mapx * 8;
		var wy = mapy * 8;

		mset(mapx, mapy, 0);

		var bird = new Bird(Npc, wx, wy, 0, 0, 0, 0);
		new Popup(bird, [
			#if debug "bird1", "bird2" #else "Chirp!", "Thanks for finding me!", "I got lost munching on some berries", "You'll need to cross the mountain",
			"I'll meet you at grandmas'",
			#end
		], function() {
			// only fire if we haven't already encountered entity
			return !GameScene.Encounters.Bird;
		}, function() {
			GameScene.Encounters.Bird = true;
			bird.anim_frame_idx = 0;
		});
		return bird;
	}

	override function draw() {
		var flip_x = 0;
		if (GameScene.Hero != null) {
			flip_x = this.pos.x - GameScene.Hero.pos.x < 0 ? 1 : 0;
		}

		Cam.spr(this.current_sprite, cast this.pos.x, cast this.pos.y, 1, flip_x);
	}

	override function update(ub:UpdateBubble) {
		super.update(ub);

		if (!GameScene.Encounters.Bird || this.finished_post_anim) {
			Timers.register_if_not_present('bird-update-before-enc', PRE_ANIM_SPEED, function() {
				anim_frame_idx = (anim_frame_idx + 1) % this.pre_encounter_animation.length;
				this.current_sprite = pre_encounter_animation[anim_frame_idx];
			});
		} else {
			Timers.register_if_not_present('bird-update-after-enc', POST_ANIM_SPEED, function() {
				anim_frame_idx += 1;
				if (anim_frame_idx >= post_encounter_animation.length) {
					finished_post_anim = true;
				} else {
					this.current_sprite = post_encounter_animation[anim_frame_idx];
				}
			});
		}
	}
}
