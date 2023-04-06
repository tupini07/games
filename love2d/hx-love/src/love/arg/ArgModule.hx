package love.arg;

import haxe.extern.Rest;
import lua.Table;
import lua.UserData;

@:native("love.arg")
extern class ArgModule
{

	public static function parseGameArguments(args:Table<Dynamic,Dynamic>) : Table<Dynamic,Dynamic>;
}