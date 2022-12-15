package physics;

class Vector2d {
	public var x:Float;
	public var y:Float;

	public function new(x, y) {
		this.x = x;
		this.y = y;
	}

	public function distance(other:Vector2d) {
		var differences = Math.pow(this.x - other.x, 2) + Math.pow(this.y - other.y, 2);
		return Math.sqrt(differences);
	}

	public function angle() {
		return Math.atan2(this.x, this.y);
	}
}
