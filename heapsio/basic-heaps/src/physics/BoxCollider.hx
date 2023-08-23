package physics;

class BoxCollider extends BaseCollider {
	public var w(default, null):Int;
	public var h(default, null):Int;

	public function new(x, y, ?w = 8, ?h = 8) {
		super(x, y);
		this.w = w;
		this.h = h;
	}

	public override function check_collision(other:BaseCollider):Bool {
		var tp = this.resolve_position();
		var op = other.resolve_position();

		if (Std.isOfType(other, BoxCollider)) {
			var obx = cast(other, BoxCollider);
			return tp.x <= op.x + obx.w && tp.x + this.w >= op.x && tp.y <= op.y + obx.h && tp.y + this.h >= op.y;
		} else {
			throw 'Trying to collide BoxCollider with unknown type "${Type.typeof(other)}"';
		}
	}
}
