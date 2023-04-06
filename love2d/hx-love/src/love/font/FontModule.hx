package love.font;
import love.filesystem.FileData;
import love.image.ImageData;
import haxe.extern.Rest;
import lua.Table;
import lua.UserData;

@:native("love.font")
extern class FontModule
{

	@:overload(function (fileName:String, glyphs:String, ?dpiscale:Float) : Rasterizer {})
	public static function newBMFontRasterizer(imageData:ImageData, glyphs:String, ?dpiscale:Float) : Rasterizer;

	public static function newGlyphData(rasterizer:Rasterizer, glyph:Float) : Void;

	public static function newImageRasterizer(imageData:ImageData, glyphs:String, ?extraSpacing:Float, ?dpiscale:Float) : Rasterizer;

	@:overload(function (data:FileData) : Rasterizer {})
	@:overload(function (?size:Float, ?hinting:HintingMode, ?dpiscale:Float) : Rasterizer {})
	@:overload(function (fileName:String, ?size:Float, ?hinting:HintingMode, ?dpiscale:Float) : Rasterizer {})
	@:overload(function (fileData:FileData, ?size:Float, ?hinting:HintingMode, ?dpiscale:Float) : Rasterizer {})
	@:overload(function (imageData:ImageData, glyphs:String, ?dpiscale:Float) : Rasterizer {})
	@:overload(function (fileName:String, glyphs:String, ?dpiscale:Float) : Rasterizer {})
	public static function newRasterizer(filename:String) : Rasterizer;

	@:overload(function (fileName:String, ?size:Float, ?hinting:HintingMode, ?dpiscale:Float) : Rasterizer {})
	@:overload(function (fileData:FileData, ?size:Float, ?hinting:HintingMode, ?dpiscale:Float) : Rasterizer {})
	public static function newTrueTypeRasterizer(?size:Float, ?hinting:HintingMode, ?dpiscale:Float) : Rasterizer;
}