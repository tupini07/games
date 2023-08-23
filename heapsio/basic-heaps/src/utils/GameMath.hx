package utils;

class GameMath {
	public static function lerp(min:Float, max:Float, value:Float):Float {
		return min + (max - min) * value;
	}

	public static function clamp(value:Float, min:Float, max:Float):Float {
		return Math.max(min, Math.min(value, max));
	}

	public static function max(options:Array<Float>):Float {
		var res = Math.NEGATIVE_INFINITY;
		for (o in options)
			res = Math.max(res, o);

		return res;
	}

	public static function sign(number:Float):Float {
		if (number >= 0)
			return 1;
		else
			return -1;
	}
}
