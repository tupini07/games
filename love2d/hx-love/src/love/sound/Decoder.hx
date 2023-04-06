package love.sound;

import haxe.extern.Rest;
import lua.Table;
import lua.UserData;

extern class Decoder extends Object
{

	public function clone() : Decoder;

	public function decode() : SoundData;

	public function getBitDepth() : Float;

	public function getChannelCount() : Float;

	public function getDuration() : Float;

	public function getSampleRate() : Float;

	public function seek(offset:Float) : Void;
}