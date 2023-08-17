package scenes;

interface IScene {
	public function update(dt:Float):Void;
	public function draw():Void;
	public function dispose():Void;
}
