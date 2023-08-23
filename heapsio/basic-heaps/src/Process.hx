import managers.*;

@:enum
abstract ProcessLayer(Int) {
	inline final Background = 1;
	inline final Unspecified = 2;
	inline final Npc = 3;
	inline final Player = 4;
	inline final Decoration = 5;
	inline final LevelMessage = 6;
	inline final Gui = 7;
	inline final Hidden = 8;
}

typedef UpdateBubble = {
	var prevent_default:Bool;
};

abstract class Process {
	final Timers = TimerManager.ME;
	final Fx = FxManager.ME;

	private static final UPDATE_ORDER:Array<ProcessLayer> = [Hidden, Background, Unspecified, Decoration, Npc, LevelMessage, Player, Gui];
	public static var ALL_BY_LAYER(default, never):Map<ProcessLayer, Array<Process>> = [for (ln in UPDATE_ORDER) ln => []];

	var destroyed = false;
	var layer(default, null):ProcessLayer;

	public function new(layer:ProcessLayer) {
		this.layer = layer;
		ALL_BY_LAYER[this.layer].push(this);
	}

	public function destroy() {
		this.destroyed = true;
	}

	public abstract function update(dt:Float, ub:UpdateBubble):Void;

	public static function reset() {
		for (layer_processes in ALL_BY_LAYER) {
			while (layer_processes.pop() != null) {}
		}
	}

	public static function update_all_processes(dt:Float) {
		var ub:UpdateBubble = {prevent_default: false};

		for (ln in UPDATE_ORDER) {
			var layer_processes = ALL_BY_LAYER[ln];
			for (process in layer_processes)
				if (process.destroyed) {
					layer_processes.remove(process);
				} else {
					process.update(dt, ub);

					// stop updating if someone requested for processes to stop being
					// updated.
					if (ub.prevent_default)
						return;
				}
		}
	}
}
