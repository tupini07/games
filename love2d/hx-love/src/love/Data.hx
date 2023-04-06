package love;

import haxe.extern.Rest;
import lua.Table;
import lua.UserData;

extern class Data extends Object
{

	public function clone() : Data;

	public function getFFIPointer() : UserData;

	public function getPointer() : UserData;

	public function getSize() : Float;

	public function getString() : String;
}