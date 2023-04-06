package love.graphics;
import love.image.PixelFormat;
import haxe.extern.Rest;
import lua.Table;
import lua.UserData;

extern class Texture extends Drawable
{

	public function getDPIScale() : Float;

	public function getDepth() : Float;

	public function getDepthSampleMode() : CompareMode;

	public function getDimensions() : TextureGetDimensionsResult;

	public function getFilter() : TextureGetFilterResult;

	public function getFormat() : PixelFormat;

	public function getHeight() : Float;

	public function getLayerCount() : Float;

	public function getMipmapCount() : Float;

	public function getMipmapFilter() : TextureGetMipmapFilterResult;

	public function getPixelDimensions() : TextureGetPixelDimensionsResult;

	public function getPixelHeight() : Float;

	public function getPixelWidth() : Float;

	public function getTextureType() : TextureType;

	public function getWidth() : Float;

	public function getWrap() : TextureGetWrapResult;

	public function isReadable() : Bool;

	public function setDepthSampleMode(compare:CompareMode) : Void;

	public function setFilter(min:FilterMode, mag:FilterMode, ?anisotropy:Float) : Void;

	@:overload(function () : Void {})
	public function setMipmapFilter(filtermode:FilterMode, ?sharpness:Float) : Void;

	public function setWrap(horiz:WrapMode, ?vert:WrapMode, ?depth:WrapMode) : Void;
}

@:multiReturn
extern class TextureGetWrapResult
{
	var horiz : WrapMode;
	var vert : WrapMode;
	var depth : WrapMode;
}

@:multiReturn
extern class TextureGetFilterResult
{
	var min : FilterMode;
	var mag : FilterMode;
	var anisotropy : Float;
}

@:multiReturn
extern class TextureGetDimensionsResult
{
	var width : Float;
	var height : Float;
}

@:multiReturn
extern class TextureGetMipmapFilterResult
{
	var mode : FilterMode;
	var sharpness : Float;
}

@:multiReturn
extern class TextureGetPixelDimensionsResult
{
	var pixelwidth : Float;
	var pixelheight : Float;
}