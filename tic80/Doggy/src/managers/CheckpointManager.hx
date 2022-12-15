package managers;

import scenes.GameScene;
import entities.Doggy;
import Process.UpdateBubble;
import physics.Vector2d;

/**
 * This type basically defines a rectangle of 8 PX of width that goes from the top-left origin
 * till the bottom right. The bottom is computed when the checkpoint is created, and basically
 * it is the cell above the first non 0 cell in the map.
 */
typedef Checkpoint = {
	x0:Int,
	y0:Int,
	x1:Int,
	y1:Int
}

class CheckpointManager extends Process {
	public static var ME(default, null):CheckpointManager;

	// Mask is used to know if the value is actually set or is just defaulting to 0
	private static inline final PMEM_MASK = 1000;

	private static inline final SAVE_IDX_CHECKPOINT_X0 = 0;
	private static inline final SAVE_IDX_CHECKPOINT_Y0 = 1;
	private static inline final SAVE_IDX_CHECKPOINT_X1 = 2;
	private static inline final SAVE_IDX_CHECKPOINT_Y1 = 3;

	private var checkpoint_origins:Array<Checkpoint> = [];
	private var current_active_checkpoint:Checkpoint = null;

	public function new() {
		super(Hidden);
		ME = this;
	}

	public function add_checkpoint_to_map(mapx:Int, mapy:Int) {
		var x0 = mapx * 8;
		var y0 = mapy * 8;

		T.mset(mapx, mapy, C.EMPTY_TILE_ID);

		var x1 = x0 + 8;

		// for y0 we need to find the first non-0 tile in the map going downwards
		// from the origin
		var y1_map = mapy;
		while (mget(mapx, y1_map) == C.EMPTY_TILE_ID) {
			y1_map += 1;
		}

		var y1 = y1_map * 8;

		this.checkpoint_origins.push({
			x0: x0,
			y0: y0,
			x1: x1,
			y1: y1,
		});
	}

	public function get_saved_checkpoint_origin():Null<Checkpoint> {
		var is_there_a_save = pmem(SAVE_IDX_CHECKPOINT_X0) > PMEM_MASK;
		if (is_there_a_save) {
			return {
				x0: pmem(SAVE_IDX_CHECKPOINT_X0) - PMEM_MASK,
				y0: pmem(SAVE_IDX_CHECKPOINT_Y0) - PMEM_MASK,
				x1: pmem(SAVE_IDX_CHECKPOINT_X1) - PMEM_MASK,
				y1: pmem(SAVE_IDX_CHECKPOINT_Y1) - PMEM_MASK,
			};
		}
		return null;
	}

	function save_checkpoint_position(checkpoint:Checkpoint) {
		pmem(SAVE_IDX_CHECKPOINT_X0, checkpoint.x0 + PMEM_MASK);
		pmem(SAVE_IDX_CHECKPOINT_Y0, checkpoint.y0 + PMEM_MASK);
		pmem(SAVE_IDX_CHECKPOINT_X1, checkpoint.x1 + PMEM_MASK);
		pmem(SAVE_IDX_CHECKPOINT_Y1, checkpoint.y1 + PMEM_MASK);
	}

	override function update(ub:UpdateBubble) {
		var hero_pos = GameScene.Hero.pos;

		for (checkpoint in this.checkpoint_origins) {
			var is_player_origin_in_checkpoint = hero_pos.x > checkpoint.x0 && hero_pos.x < checkpoint.x1 && hero_pos.y > checkpoint.y0
				&& hero_pos.y < checkpoint.y1;

			if (is_player_origin_in_checkpoint && this.current_active_checkpoint != checkpoint) {
				this.current_active_checkpoint = checkpoint;
				save_checkpoint_position(checkpoint);

				// no need to keep iterating for this UPDATE
				return;
			}
		}
	}
}
