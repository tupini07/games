package managers;

class TimerEntry {
	public var name:String;
	public var remaining:Float;
	public var callback:() -> Void;

	public function new(name, time, callback) {
		this.name = name;
		this.remaining = time;
		this.callback = callback;
	}
}

class TimerManager {
	public static var ME:TimerManager;

	public var timers:Map<String, TimerEntry> = [];

	public function new() {
		ME = this;
	}

	public function register_if_not_present(name, time, callback) {
		if (query_timer(name) == null) {
			register_timer_override(name, time, callback);
			return true;
		}
		return false;
	}

	public function register_timer_override(name, time, callback) {
		this.timers.set(name, new TimerEntry(name, time, callback));
	}

	public function query_timer(name):Null<TimerEntry> {
		var timer = this.timers.get(name);
		if (timer != null) {
			return timer;
		} else {
			return null;
		}
	}

	public function cancel_timer(name):Bool {
		return this.timers.remove(name);
	}

	public function update_timers() {
		for (timer in this.timers) {
			timer.remaining -= 1;
			if (timer.remaining <= 0) {
				timer.callback();
				this.timers.remove(timer.name);
			}
		}
	}
}
