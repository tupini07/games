package love.graphics;
import love.image.ImageData;
import haxe.extern.Rest;
import lua.Table;
import lua.UserData;

extern class Canvas extends Texture
{

	public function generateMipmaps() : Void;

	public function getMSAA() : Float;

	public function getMipmapMode() : MipmapMode;

	@:overload(function (slice:Float, ?mipmap:Float, x:Float, y:Float, width:Float, height:Float) : ImageData {})
	public function newImageData() : ImageData;

	public function renderTo(func:Dynamic) : Void;
}