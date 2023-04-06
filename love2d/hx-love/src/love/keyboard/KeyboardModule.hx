package love.keyboard;

import haxe.extern.Rest;
import lua.Table;
import lua.UserData;

@:native("love.keyboard")
extern class KeyboardModule
{

	public static function getKeyFromScancode(scancode:Scancode) : KeyConstant;

	public static function getScancodeFromKey(key:KeyConstant) : Scancode;

	public static function hasKeyRepeat() : Bool;

	public static function hasScreenKeyboard() : Bool;

	public static function hasTextInput() : Bool;

	@:overload(function (key:KeyConstant, args:Rest<KeyConstant>) : Bool {})
	public static function isDown(key:KeyConstant) : Bool;

	public static function isScancodeDown(scancode:Scancode, args:Rest<Scancode>) : Bool;

	public static function setKeyRepeat(enable:Bool) : Void;

	@:overload(function (enable:Bool, x:Float, y:Float, w:Float, h:Float) : Void {})
	public static function setTextInput(enable:Bool) : Void;
}