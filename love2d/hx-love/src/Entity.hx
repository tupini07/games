import Process.UpdateBubble;
import Process.ProcessLayer;
import physics.BoxCollider;
import physics.Vector2d;

class Entity extends Process {
	public var pos(default, null):Vector2d;

	var direction:Int = 1;
	var delta_v:Vector2d;
	var acceleration:Vector2d;
	var collider:Null<BoxCollider>;
	var is_on_ground:Bool = false;
	var has_just_landed = false;

	public function new(layer:ProcessLayer, x:Int, y:Int, dx:Float, dy:Float, accx:Float, accy:Float, ?collider:BoxCollider) {
		super(layer);

		this.pos = new Vector2d(x, y);
		this.delta_v = new Vector2d(dx, dy);
		this.acceleration = new Vector2d(accx, accy);

		if (collider != null) {
			this.collider = collider;
			collider.attach_to_entity(this);
		}
	}

	private function update_physics() {
		if (this.collider == null) {
			return;
		}

		var collider_pos = this.collider.resolve_position();

		// horizontal
		if (!WorldMap.is_solid_area(collider_pos.x + this.delta_v.x, collider_pos.y, this.collider.w, this.collider.h)) {
			var new_x = this.pos.x + this.delta_v.x;

			var x_difference = new_x - this.pos.x;
			if (x_difference != 0)
				this.direction = x_difference < 0 ? -1 : 1;

			this.pos.x = new_x;
		} else {
			this.delta_v.x = 0;
		}

		var was_on_ground = this.is_on_ground;

		// vertical
		if (!WorldMap.is_solid_area(collider_pos.x, collider_pos.y + this.delta_v.y, this.collider.w, this.collider.h)) {
			this.is_on_ground = false;
			this.pos.y += this.delta_v.y;
		} else {
			this.is_on_ground = true;
			this.delta_v.y = 0;
		}

		this.has_just_landed = !was_on_ground && this.is_on_ground;

		this.delta_v.x += this.acceleration.x;
		this.delta_v.y += this.acceleration.y;

		this.delta_v.x *= 0.32;
		this.delta_v.x = Math.abs(this.delta_v.x) > 0.1 ? this.delta_v.x : 0;
		this.delta_v.y = Math.abs(this.delta_v.y) > 0.1 ? this.delta_v.y : 0;
	}

	override function update(ub:UpdateBubble) {
		update_physics();
	}

	override function draw() {}
}
