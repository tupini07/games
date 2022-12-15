package utils;

class Camera {
	public static var off_x(default, null):Int = 0;
	public static var off_y(default, null):Int = 0;

	static var trackingEntity(default, null):Null<Entity>;

	public static inline function has_target():Bool {
		return trackingEntity != null;
	}

	static inline final TRANSPARENT_COLOR = 0;

	public static function trackEntity(e:Entity) {
		trackingEntity = e;
	}

	public static function updateTracking() {
		if (trackingEntity != null) {
			// center on entity
			// off_x = Math.floor(Math.max(0, trackingEntity.pos.x - C.SCREEN_WIDTH / 2.2));
			// off_y = Math.floor(Math.max(0, trackingEntity.pos.y - C.SCREEN_HEIGHT / 2.3));
			var desiredX = trackingEntity.pos.x - C.SCREEN_WIDTH / 2.2;
			var desiredY = trackingEntity.pos.y - C.SCREEN_HEIGHT / 2.3;

			off_x = Math.floor(GM.clamp(GM.lerp(off_x, desiredX, 0.05), 0, C.MAP_PX_WIDTH));
			off_y = Math.floor(GM.clamp(GM.lerp(off_y, desiredY, 0.05), 0, C.MAP_PX_HEIGHT));
		}
	}

	public static function updateCamera() {
		updateTracking();
	}

	public static function get_len_of_print(text:String, ?fixed:Bool, ?scale:Int, ?smallfont:Bool):Int {
		return T.print(text, off_x - 200, off_y - 200, 0, fixed, scale, smallfont);
	}

	public static function print(text:String, ?x:Int, ?y:Int, ?color:Int, ?fixed:Bool, ?scale:Int, ?smallfont:Bool):Int {
		if (x != null && y != null) {
			return T.print(text, x - off_x, y - off_y, color, fixed, scale, smallfont);
		} else {
			return T.print(text);
		}
	}

	public static function line(x0:Int, y0:Int, x1:Int, y1:Int, color:Int) {
		T.line(x0 - off_x, y0 - off_y, x1 - off_x, y1 - off_y, color);
	}

	public static function rect(x:Int, y:Int, w:Int, h:Int, color:Int) {
		T.rect(x - off_x, y - off_y, w, h, color);
	}

	public static function rectb(x:Int, y:Int, w:Int, h:Int, color:Int) {
		T.rectb(x - off_x, y - off_y, w, h, color);
	}

	public static function pix(x:Int, y:Int, ?color:Int):Int {
		return T.pix(x - off_x, y - off_y, color);
	}

	@broken
	public static function draw_map_around_target() {
		if (trackingEntity == null) {
			throw "Trying to draw map around null target";
		}

		var leftmost_cell = Math.floor(off_x / 8);
		var topmost_cell = Math.floor(off_y / 8);

		Cam.map(leftmost_cell, topmost_cell, C.MAP_REGION_CELLS_WIDTH, C.MAP_REGION_CELLS_HEIGHT, cast off_x, cast off_y);
	}

	public static function map(x:Int, y:Int, w:Int = 30, h:Int = 17, sx:Int = 0, sy:Int = 0, ?scale:Int = 1) {
		T.map(x, y, w, h, sx - off_x, sy - off_y, TRANSPARENT_COLOR, scale);
	}

	public static function spr(sprite_num:Int, x:Int, y:Int, scale:Int = 1, flip:Int = 0, rotate:Int = 0, w:Int = 1, h:Int = 1) {
		T.spr(sprite_num, x - off_x, y - off_y, TRANSPARENT_COLOR, scale, flip, rotate, w, h);
	};

	public static function circ(x:Int, y:Int, r:Int, color:Int) {
		T.circ(x - off_x, y - off_y, r, color);
	}
}
