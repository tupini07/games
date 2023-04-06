package love.graphics;
import love.image.ImageData;
import haxe.extern.Rest;
import lua.Table;
import lua.UserData;

extern class Image extends Texture
{

	public function getFlags() : Table<Dynamic,Dynamic>;

	public function isCompressed() : Bool;

	public function replacePixels(data:ImageData, slice:Float, ?mipmap:Float, ?x:Float, ?y:Float, reloadmipmaps:Bool) : Void;
}