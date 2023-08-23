package managers;

import physics.Vector2d;
import Process.UpdateBubble;

typedef Particle = {
	x:Int,
	y:Int,
	dx:Int,
	dy:Int,
	color:Int,
	lifetime:Int,
	draw:(Particle) -> Void,
	update:(Particle) -> Void,
};

class FxManager extends Process {
	public static var ME(default, null):FxManager;

	final particles:Array<Particle> = [];

	public function new() {
		super(Decoration);
		ME = this;
	}

	public function update(dt:Float, ub:UpdateBubble) {
		for (p in this.particles)
			p.update(p);
	}

	public function add_pixel_particle(x, y, dx, dy, color, lifetime) {
		this.particles.push({
			x: x,
			y: y,
			dx: dx,
			dy: dy,
			color: color,
			lifetime: lifetime,
			draw: pixel_particle_renderer,
			update: simple_velocity_updater
		});
	}

	public function add_circle_particle(x, y, dx, dy, radius, color, lifetime) {
		this.particles.push({
			x: x,
			y: y,
			dx: dx,
			dy: dy,
			lifetime: lifetime,
			color: color,
			draw: make_circle_renderer(radius),
			update: simple_velocity_updater,
		});
	}

	function make_circle_renderer(radius) {
		return function(p:Particle) {
			// Cam.circ(p.x, p.y, radius, p.color);
		};
	}

	static function pixel_particle_renderer(particle:Particle) {
		// Cam.pix(particle.x, particle.y, particle.color);
	}

	static function simple_velocity_updater(particle:Particle) {
		particle.lifetime -= 1;
		if (particle.lifetime < 0) {
			ME.particles.remove(particle);
			return;
		}

		particle.x += particle.dx;
		particle.y += particle.dy;
	}

	public function add_particle_circle_cloud(amount:Int, colors:Array<Int>, posMean:Vector2d, posDeviation:Vector2d, radiusMean:Int, radiusDeviation:Int,
			directionMean:Vector2d, directionDeviation:Vector2d, lifetimeMean:Int, lifetimeDeviation:Int) {
		for (idx in 0...amount) {
			final color = GR.pick_random_item(colors);

			final x = GR.get_value_in_distribution(posMean.x, posDeviation.x);
			final y = GR.get_value_in_distribution(posMean.y, posDeviation.y);

			final dx = GR.get_value_in_distribution(directionMean.x, directionDeviation.x);
			final dy = GR.get_value_in_distribution(directionMean.y, directionDeviation.y);

			final radius = GR.get_value_in_distribution(radiusMean, radiusDeviation);

			final lifetime = GR.get_value_in_distribution(lifetimeMean, lifetimeDeviation);

			this.add_circle_particle(cast x, cast y, cast dx, cast dy, cast radius, color, cast lifetime);
		}
	}
}
