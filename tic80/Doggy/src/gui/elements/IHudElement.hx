package gui.elements;

import managers.TimerManager;

interface IHudElement {
	public function update(timers:TimerManager):Void;
	public function draw():Void;
}
