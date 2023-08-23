package entities;

import Process.UpdateBubble;

class PimpCamera extends Process {
	var camera:h2d.Camera;

	public function new(camera:h2d.Camera) {
		super(Gui);

		this.camera = camera;

		camera.setAnchor(0.5, 0.5);
		camera.clipViewport = true;
	}

	public function update(dt:Float, ub:UpdateBubble) {}
}
