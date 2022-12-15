package gui.elements;

import managers.TimerManager;
import scenes.GameScene;

class MissingAnimalsHud implements IHudElement {
	var expand_progress = 0;

	static inline final GIRL_SPRITE = 262;
	static inline final CAT_SPRITE = 263;
	static inline final BIRD_SPRITE = 261;
	static inline final UNKNOWN_SPRITE = 260;

	final component_width = 2 + 3 * 9;
	final component_height = 12;
	final x_origin:Int;

	public function new() {
		// var half_screen = C.SCREEN_WIDTH / 2;
		// x_origin = Math.floor(half_screen - component_width / 2);
		x_origin = Math.floor((C.SCREEN_WIDTH / 4) * 3);
	}

	public function update(timers:TimerManager) {
		if (GameScene.Encounters.Girl && this.expand_progress < 100) {
			timers.register_if_not_present('hud-expand-missing-animals', 1, function() this.expand_progress += 1);
		}
	}

	public function draw() {
		var resolved_x_orig = Cam.off_x + x_origin;
		var resolved_y_orig = Math.floor(Cam.off_y - (component_height * (1 - this.expand_progress / 100)));
		Cam.rect(resolved_x_orig, resolved_y_orig, component_width, component_height, 12);

		var icons_y_orig = resolved_y_orig + 1;
		Cam.spr(GameScene.Encounters.Girl ? GIRL_SPRITE : UNKNOWN_SPRITE, resolved_x_orig + 2, icons_y_orig);
		Cam.spr(GameScene.Encounters.Cat ? CAT_SPRITE : UNKNOWN_SPRITE, resolved_x_orig + 2 + 9, icons_y_orig);
		Cam.spr(GameScene.Encounters.Bird ? BIRD_SPRITE : UNKNOWN_SPRITE, resolved_x_orig + 2 + 18, icons_y_orig);

		// don't draw lines if hud is hidden
		if (this.expand_progress == 0)
			return;

		final BORDER_COLOR = 10;
		Cam.line(resolved_x_orig, resolved_y_orig, resolved_x_orig, resolved_y_orig + component_height, BORDER_COLOR);
		Cam.line(resolved_x_orig, resolved_y_orig
			+ component_height, resolved_x_orig
			+ component_width, resolved_y_orig
			+ component_height, BORDER_COLOR);
		Cam.line(resolved_x_orig
			+ component_width, resolved_y_orig, resolved_x_orig
			+ component_width, resolved_y_orig
			+ component_height, BORDER_COLOR);
	}
}
