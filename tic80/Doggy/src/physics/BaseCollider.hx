package physics;

class BaseCollider {
	var x:Int;
	var y:Int;

	var collides_with_layes:Array<Int> = [];

	var entity:Null<Entity>;

	public function new(x, y) {
		this.x = x;
		this.y = y;
	}

	public function attach_to_entity(e:Entity) {
		this.entity = e;
	}

	public function resolve_position():Vector2d {
		if (this.entity == null) {
			return new Vector2d(this.x, this.y);
		}

		return new Vector2d(this.entity.pos.x + this.x, this.entity.pos.y + this.y);
	}

	public function resolve_with_custom_position(pos:Vector2d):Vector2d {
		return new Vector2d(pos.x + this.x, pos.y + this.y);
	}

	public function check_collision(other:BaseCollider):Bool {
		throw "Not Implemented";
	}
}
