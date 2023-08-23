package utils;

class GameRandom {
	public static function get_value_in_distribution(mean:Float, std:Float):Float {
		return (mean - std) + (Math.random() * std * 2);
	}

	public static function random_in_range(min:Float, max:Float):Float {
		var difference = max - min;
		return min + (Math.random() * difference);
	}

	public static function pick_random_item<T>(items:Array<T>):T {
		final idx = Math.ceil(random_in_range(0, items.length - 1));
		return items[idx];
	}
}
