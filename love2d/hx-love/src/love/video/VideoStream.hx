package love.video;

import haxe.extern.Rest;
import lua.Table;
import lua.UserData;

extern class VideoStream extends Object
{

	public function getFilename() : String;

	public function isPlaying() : Bool;

	public function pause() : Void;

	public function play() : Void;

	public function rewind() : Void;

	public function seek(offset:Float) : Void;

	public function tell() : Float;
}