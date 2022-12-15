import managers.CheckpointManager;
import Tic80.SpriteFlags;
import entities.*;
import entities.decorations.*;

class WorldMap {
	public static function cell_has_flag(mapx, mapy, flag:SpriteFlags) {
		var spritnum = mget(mapx, mapy);
		return fget(spritnum, flag);
	}

	public static function is_solid(x:Float, y:Float):Bool {
		return cell_has_flag(Math.floor(x / 8), Math.floor(y / 8), Solid);
	}

	public static function is_solid_area(x, y, w, h):Bool {
		return is_solid(x, y) || is_solid(x + w, y) || is_solid(x, y + h) || is_solid(x + w, y + h) || is_solid(x, y + h / 2) || is_solid(x + w, y + h / 2);
	}

	public static function init_map_entities() {
		for (y in 0...C.MAP_TOTAL_CELLS_HEIGHT) {
			for (x in 0...C.MAP_TOTAL_CELLS_WIDTH) {
				var sprite_num = mget(x, y);

				switch sprite_num {
					case 15:
						Doggy.add_to_map(x, y);
					case 14:
						Girl.add_to_map(x, y);
					case 31:
						Cat.add_to_map(x, y);
					case 47:
						Bird.add_to_map(x, y);
					case 30:
						Granny.add_to_map(x, y);
					case 63:
						CheckpointManager.ME.add_checkpoint_to_map(x, y);
					case 4, 20, 36, 21, 37, 55, 70, 86, 102:
						WaterDecoration.add_to_map(x, y);
				}
			}
		}
	}
}
