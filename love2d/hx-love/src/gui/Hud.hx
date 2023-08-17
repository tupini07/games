package gui;

import Process.UpdateBubble;
import gui.elements.*;
import gui.elements.IHudElement;

class Hud extends Process {
	var hud_elements:Array<IHudElement>;

	public function new() {
		super(Gui);

		hud_elements = [new MissingAnimalsHud()];
	}

	override function update(ub:UpdateBubble) {
		for (elem in this.hud_elements)
			elem.update(this.Timers);
	}

	override function draw() {
		for (elem in this.hud_elements)
			elem.draw();
	}
}
