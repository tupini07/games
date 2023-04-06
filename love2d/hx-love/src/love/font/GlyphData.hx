package love.font;
import love.image.PixelFormat;
import haxe.extern.Rest;
import lua.Table;
import lua.UserData;

extern class GlyphData extends Data
{

	public function getAdvance() : Float;

	public function getBearing() : GlyphDataGetBearingResult;

	public function getBoundingBox() : GlyphDataGetBoundingBoxResult;

	public function getDimensions() : GlyphDataGetDimensionsResult;

	public function getFormat() : PixelFormat;

	public function getGlyph() : Float;

	public function getGlyphString() : String;

	public function getHeight() : Float;

	public function getWidth() : Float;
}

@:multiReturn
extern class GlyphDataGetBearingResult
{
	var bx : Float;
	var by : Float;
}

@:multiReturn
extern class GlyphDataGetBoundingBoxResult
{
	var x : Float;
	var y : Float;
	var width : Float;
	var height : Float;
}

@:multiReturn
extern class GlyphDataGetDimensionsResult
{
	var width : Float;
	var height : Float;
}