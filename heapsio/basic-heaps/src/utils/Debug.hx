package utils;

@:access(Entity)
class Debug {
	static function get_all_process_entities():Array<Entity> {
		return [
			for (layer in Process.ALL_BY_LAYER)
				for (p in layer)
					if (Std.isOfType(p, Entity))
						cast(p, Entity)
		];
	}

	public static function draw_entity_positions() {
		for (e in get_all_process_entities()) {
			var t = '${Math.floor(e.pos.x)},${Math.floor(e.pos.y)}';
			var l = Cam.get_len_of_print(t, true, 1, true);
			Cam.print(t, Math.round((e.pos.x + 4) - l / 2), cast e.pos.y + 5, 13, true, 1, true);
		}
	}

	public static function draw_entity_colliders() {
		for (e in get_all_process_entities()) {
			if (e.collider == null)
				continue;
			var pos = e.collider.resolve_position();
			Cam.rectb(cast pos.x, cast pos.y, e.collider.w, e.collider.h, 2);
		}
	}

	public static function draw() {
		// draw_entity_colliders();
		// draw_entity_positions();
	}
}
