package entities.decorations;

import Process.UpdateBubble;

class WaterDecoration extends Process {
	static inline final WATER_LIFETIME = 5;

	final POSSIBLE_COLORS = [8, 9, 10, 11, 12];

	final decoration_id:String;
	final tile_x:Int;
	final tile_y:Int;

	var current_x = -1;
	var current_y = -1;
	var current_color = -1;

	public function new(tile_x, tile_y) {
		super(Decoration);
		this.tile_x = tile_x;
		this.tile_y = tile_y;
		this.decoration_id = 'water-deco-${Math.random()}';
	}

	public static function add_to_map(mapx:Int, mapy:Int) {
		var wx = mapx * 8;
		var wy = mapy * 8;

		var waterDec = new WaterDecoration(wx, wy);
	}

	override function draw() {
		if (this.current_x == -1 && this.current_color == -1) {
			if (Math.random() > 0.7)
				return;

			this.current_x = this.tile_x + Math.round(Math.random() * 6) + 1;
			this.current_y = this.tile_y + Math.round(Math.random() * 8);
			this.current_color = POSSIBLE_COLORS[Math.round(Math.random() * POSSIBLE_COLORS.length)];

			Timers.register_if_not_present('water-decoration-reset-${this.decoration_id}', WATER_LIFETIME, function() {
				this.current_color = this.current_x = this.current_y = -1;
			});
		} else {
			Timers.register_if_not_present('water-decoration-go-down-${this.decoration_id}', 2, function() {
				this.current_y = cast GM.clamp(this.current_y + 1, this.tile_y, this.tile_y + 8);
			});

			Cam.pix(this.current_x, this.current_y, this.current_color);
		}
	}

	override function update(ub:UpdateBubble) {}
}
