package entities.decorations;

import Process.UpdateBubble;

@:enum
abstract VeilStates(Int) {
	inline final Closed = 0;
	inline final Opening = 1;
	inline final Open = 2;
	inline final Closing = 3;
}

class GameVeil extends Process {
	public static var ME(default, null):GameVeil;

	private static inline final VEIL_SPEED = 0.25;

	private var closed_percentage = 125.0;
	private var current_state:VeilStates = Opening;

	public function new() {
		super(Gui);
		ME = this;
	}

	public function open_veil() {
		#if debug
		if (this.current_state != Closed) {
			throw "Tried to open the veil when the state was not Closed";
		}
		#end

		this.current_state = Opening;
		this.closed_percentage = 100;
	}

	public function close_veil() {
		#if debug
		if (this.current_state != Open) {
			throw "Tried to open the veil when the state was not Open";
		}
		#end

		this.current_state = Closing;
		this.closed_percentage = 0;
	}

	override function update(ub:UpdateBubble) {
		if (this.current_state == Opening) {
			this.closed_percentage -= VEIL_SPEED;
			if (this.closed_percentage <= 0) {
				this.current_state = Open;
			}
		} else if (this.current_state == Closing) {
			this.closed_percentage += VEIL_SPEED;
			if (this.closed_percentage >= 100) {
				this.current_state = Closed;
			}
		}
	}

	override function draw() {
		var height = C.SCREEN_HEIGHT * (this.closed_percentage / 100);

		Cam.rect(Cam.off_x, Cam.off_y, C.SCREEN_WIDTH, cast height, 13);
	}
}
