package love.font;

import haxe.extern.Rest;
import lua.Table;
import lua.UserData;

extern class Rasterizer extends Object
{

	public function getAdvance() : Float;

	public function getAscent() : Float;

	public function getDescent() : Float;

	public function getGlyphCount() : Float;

	@:overload(function (glyphNumber:Float) : GlyphData {})
	public function getGlyphData(glyph:String) : GlyphData;

	public function getHeight() : Float;

	public function getLineHeight() : Float;

	public function hasGlyphs(glyph1:Dynamic, glyph2:Dynamic, args:Rest<Dynamic>) : Bool;
}