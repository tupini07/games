import love.mouse.MouseModule;
import love.mouse.Cursor;
import physics.Vector2d;
import love.graphics.GraphicsModule;
import love.graphics.DrawMode;
import love.Love;

class Main {
	static function main() {
		var pos = new Vector2d(0, 0);

		Love.update = function(dt:Float) {
			var mousePos = MouseModule.getPosition();
			pos.x = mousePos.x;
			pos.y = mousePos.y;
		}

		Love.draw = function() {
			GraphicsModule.rectangle(DrawMode.Fill, pos.x, pos.y, 100, 100);
		}

		trace("Hello, world!");
	}
}
