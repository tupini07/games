package entities;

import managers.CheckpointManager;
import physics.Vector2d;
import Process.UpdateBubble;
import scenes.GameScene;
import physics.BoxCollider;
import Tic80.*;

class Doggy extends Entity {
	static inline final idleTimerName = 'doggy-idle';
	static inline final veryIdleTimerName = 'doggy-very-idle';
	static inline final tailTimerName = 'doggy-tail';
	static inline final walkingOpenTimerName = 'doggy-walk';

	static inline final DASH_DELAY = 3;
	static inline final DASH_AMOUNT = 10;

	public var has_seen_girl = false;

	var is_idle = false;
	var is_walking_open = false;
	var is_very_idle = false;
	var tail_state = true;

	// boon trackers
	var has_double_jumped = false;
	var dash_timer = 0;

	public static function add_to_map(mapx:Int, mapy:Int):Doggy {
		var wx = mapx * 8;
		var wy = mapy * 8;

		mset(mapx, mapy, 0);

		#if !debug
		// check if there is a saved position for Doggy
		var current_checkpoint = CheckpointManager.ME.get_saved_checkpoint_origin();
		if (current_checkpoint != null) {
			wx = current_checkpoint.x0;
			wy = current_checkpoint.y0;
		}
		#end

		var d = new Doggy(Player, wx, wy, 0, 0, 0, 0.2, new BoxCollider(1, 1, 5, 6));
		Cam.trackEntity(d);
		GameScene.Hero = d;
		return d;
	}

	/**
	 * After having encountered the bird, Doggy is able to double jump.
	 */
	function check_bird_boon() {
		if (!GameScene.Encounters.Bird)
			return;

		if (this.is_on_ground)
			this.has_double_jumped = false;

		if (!this.is_on_ground && !this.has_double_jumped && (btnp(Up) || btnp(A))) {
			this.has_double_jumped = true;
			this.delta_v.y = -2;

			Fx.add_particle_circle_cloud(30, [11, 12, 13], new Vector2d(this.pos.x + 4, this.pos.y + 8), new Vector2d(4, 1), 1, 1, new Vector2d(0, 0),
				new Vector2d(0, 0), 8, 5);
		}
	}

	function check_cat_boon() {
		if (!GameScene.Encounters.Cat)
			return;

		this.dash_timer = cast Math.max(0, this.dash_timer - 1);

		final abs_dx = Math.abs(this.delta_v.x);
		final has_any_velocity = abs_dx > 0;
		final particle_colors = [2, 3, 4, 5, 11, 12];

		if (this.dash_timer == 0 && has_any_velocity && btnp(B)) {
			this.dash_timer = DASH_DELAY;
			Fx.add_particle_circle_cloud(30, particle_colors, new Vector2d(this.pos.x, this.pos.y + 4), new Vector2d(2, 2), 1, 1,
				new Vector2d(this.delta_v.x * -1, 0), new Vector2d(abs_dx / 2, 1), 10, 10);
		}

		if (this.dash_timer > 0 && has_any_velocity) {
			this.delta_v.x += DASH_AMOUNT * GM.sign(this.delta_v.x);
			Fx.add_particle_circle_cloud(10, particle_colors, new Vector2d(this.pos.x, this.pos.y + 4), new Vector2d(2, 2), 1, 1,
				new Vector2d(GM.sign(this.delta_v.x) * -1, 0), new Vector2d(1, 1), 10, 10);
		}
	}

	public override function update(ub:UpdateBubble) {
		super.update(ub);

		if (btn(Right))
			this.delta_v.x += 1;

		if (btn(Left))
			this.delta_v.x -= 1;

		if ((btnp(Up) || btnp(A)) && this.is_on_ground) {
			this.delta_v.y = -2;
			Fx.add_particle_circle_cloud(5, [11, 12, 13], new Vector2d(this.pos.x + 4, this.pos.y + 8), new Vector2d(4, 1), 1, 1, new Vector2d(0, 0),
				new Vector2d(0, 0), 8, 5);
		}

		var is_moving_x = Math.abs(delta_v.x) > 0.2;
		if (is_moving_x) {
			Timers.register_if_not_present(walkingOpenTimerName, 10, function() this.is_walking_open = !this.is_walking_open);
		} else {
			Timers.cancel_timer(walkingOpenTimerName);
			this.is_walking_open = false;
		}

		if (is_moving_x || !is_on_ground) {
			Timers.cancel_timer(idleTimerName);
			Timers.cancel_timer(tailTimerName);
			is_idle = false;
			is_very_idle = false;
		} else if (!is_idle) {
			Timers.register_if_not_present(idleTimerName, 60, function() {
				this.is_idle = true;
				Timers.register_if_not_present(veryIdleTimerName, 180, function() this.is_very_idle = true);
			});
		}

		if (is_idle) {
			Timers.register_if_not_present(tailTimerName, 10, function() this.tail_state = !this.tail_state);
		}

		if (this.has_just_landed) {
			var abs_x_speed = Math.abs(this.delta_v.x);
			var dust_x_speed = abs_x_speed == 0 ? 0 : GM.sign(this.delta_v.x) * -0.2;
			Fx.add_particle_circle_cloud(5, [11, 12, 13], new Vector2d(this.pos.x + 4, this.pos.y + 8), new Vector2d(4, 1), 1, 1,
				new Vector2d(dust_x_speed, 0), new Vector2d(0, 0), 8, 5);
		}

		check_cat_boon();
		check_bird_boon();
	}

	public override function draw() {
		super.draw();

		var spritn:Int = 256;

		if (this.is_idle) {
			if (this.is_very_idle) {
				spritn = this.tail_state ? 258 : 259;
			} else {
				spritn = this.tail_state ? 256 : 272;
			}
		} else if (is_on_ground) {
			spritn = this.is_walking_open ? 257 : 256;
		} else if (!is_on_ground) {
			spritn = 257;
		}

		Cam.spr(spritn, cast this.pos.x, cast this.pos.y, 1, this.direction == -1 ? 1 : 0);
	}
}
