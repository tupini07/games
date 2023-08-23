package utils;

import physics.Vector2d;

class WrapTextResult {
	public var text:String;
	public var height_px:Int;
	public var width_px:Int;

	public function new(text:String, width:Int, height:Int) {
		this.text = text;
		this.width_px = width;
		this.height_px = height;
	}
}

class Text {
	public static function wrap_text_at_length(text:String, length:Int):WrapTextResult {
		var result = "";
		var current_line = "";

		for (c in text.split(' ')) {
			if (current_line.length >= length) {
				result += current_line + "\n";
				current_line = "";
			}
			current_line += c + ' ';
		}

		result += current_line;

		var lines = result.split("\n");
		var max_len = cast GM.max([for (l in lines) l.length]);

		return new WrapTextResult(result, max_len * 5, lines.length * 6);
	}
}
