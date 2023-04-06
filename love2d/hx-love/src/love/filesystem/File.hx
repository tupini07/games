package love.filesystem;
import love.Data;
import love.data.ContainerType;
import haxe.extern.Rest;
import lua.Table;
import lua.UserData;

extern class File extends Object
{

	public function close() : Bool;

	public function flush() : FileFlushResult;

	public function getBuffer() : FileGetBufferResult;

	public function getFilename() : String;

	public function getMode() : FileMode;

	public function getSize() : Float;

	public function isEOF() : Bool;

	public function isOpen() : Bool;

	public function lines() : Dynamic;

	public function open(mode:FileMode) : FileOpenResult;

	@:overload(function (container:ContainerType, ?bytes:Float) : FileReadResult {})
	public function read(?bytes:Float) : FileReadResult;

	public function seek(pos:Float) : Bool;

	public function setBuffer(mode:BufferMode, ?size:Float) : FileSetBufferResult;

	public function tell() : Float;

	@:overload(function (data:Data, ?size:Float) : FileWriteResult {})
	public function write(data:String, ?size:Float) : FileWriteResult;
}

@:multiReturn
extern class FileGetBufferResult
{
	var mode : BufferMode;
	var size : Float;
}

@:multiReturn
extern class FileFlushResult
{
	var success : Bool;
	var err : String;
}

@:multiReturn
extern class FileOpenResult
{
	var ok : Bool;
	var err : String;
}

@:multiReturn
extern class FileSetBufferResult
{
	var success : Bool;
	var errorstr : String;
}

@:multiReturn
extern class FileWriteResult
{
	var success : Bool;
	var errorstr : String;
}

@:multiReturn
extern class FileReadResult
{
	var contents : Dynamic;
	var size : Float;
}