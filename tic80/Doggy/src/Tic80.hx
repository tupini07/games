package;

@:enum
abstract Keys(Int) {
	inline final Up = 0;
	inline final Down = 1;
	inline final Left = 2;
	inline final Right = 3;
	inline final A = 4;
	inline final B = 5;
	inline final X = 6;
	inline final Y = 7;
}

@:enum
abstract SpriteFlags(Int) {
	inline final Solid = 0;
}

@:native("__TIC80WRAPPER")
extern class Tic80 {
	/**
	 * This function allows you to read the status of one of TIC's buttons.
	 * It returns true only if the key has been pressed since the last frame.
	 * You can also use the optional hold and period parameters which allow you to check if a button is being held down. After the time specified by hold has elapsed, btnp will return true each time period is passed if the key is still down. For example, to re-examine the state of button '0' after 2 seconds and continue to check its stat
	 * This function allows you to read the status of one of the buttons attached to TIC. The function returns true if the key with the supplied id is currently in the pressed state. It remains true for as long as the key is held down. If you want to test if a key was just pressed, use btnp instead.
	 * @param id number The id of the key we want to interrogate, see the [key map](https://github.com/nesbox/TIC-80/wiki/key-map) for reference
	 * @return pressed boolean
	 */
	public static function btn(id:Keys):Bool;

	/**
	 * This function allows you to read the status of one of TIC's buttons.
	 * It returns true only if the key has been pressed since the last frame.
	 * You can also use the optional hold and period parameters which allow you to check if a button is being held down. After the time specified by hold has elapsed, btnp will return true each time period is passed if the key is still down. For example, to re-examine the state of button '0' after 2 seconds and continue to check its state every 1/10th of a second, you would use btnp(0, 120, 6). Since time is expressed in ticks and TIC runs at 60 frames per second, we use the value of 120 to wait 2 seconds and 6 ticks (ie 60/10) as the interval for re-checking.
	 * @param id number The id of the key we wish to interrogate - see the [key map](https://github.com/nesbox/TIC-80/wiki/key-map) for reference
	 * @param hold number The time (in ticks) the key must be pressed before re-checking
	 * @param period number The the amount of time (in ticks) after hold before this function will return true again.
	 * @return pressed boolean
	 */
	public static function btnp(id:Keys, ?hold:Int, ?period:Int):Bool;

	/**
	 * This function limits drawing to a clipping region or 'viewport' defined by x,y,w,h. Things drawn outside of this area will not be visible.
	 * Calling clip() with no parameters will reset the drawing area to the entire screen.
	 * @param x number x coordinate of the top left of the clipping region
	 * @param y number y coordinate of the top left of the clipping region
	 * @param w number Width of the drawing area in pixels
	 * @param h number Height of the drawing area in pixels
	 */
	public static function clip(x:Int, y:Int, w:Int, h:Int):Void;

	/**
	 * Clear the screen.
	 * When called this function clear all the screen using the color passed as argument. If no parameter is passed first color (0) is used.
	 * Tips: Use a color over 15 to see some special fill pattern
	 * @param color number The index (0 to 15) of the color in the current
	 */
	public static function cls(?color:Int):Void;

	/**

		* This function draws a filled circle of the desired radius and color with its center at x, y. It uses the Bresenham algorithm.
		* @param x number The x coordinate of the circle center
		* @param y number The y coordinate of the circle center
		* @param r number The radius of the circle in pixels
		* @param color number The index of the desired color in the current [palette](https://github.com/nesbox/TIC-80/wiki/palette)
	 */
	public static function circ(x:Int, y:Int, r:Int, color:Int):Void;

	/**
	 * Draws the circumference of a circle with its center at x, y using the radius and color requested.
	 * It uses the Bresenham algorithm.
	 * @param x number The x coordinate of the circle's center
	 * @param y number The y coordinate of the circle's center
	 * @param r number The radius of the circle in pixels
	 * @param color number The index of the desired color in the current [palette](https://github.com/nesbox/TIC-80/wiki/palette)
	 */
	public static function circb(x:Int, y:Int, r:Int, color:Int):Void;

	/**
	 * Interrupts program execution and returns to the console when the TIC function ends.
	 */
	public static function exit():Void;

	/**
	 * Returns true if the specified flag of the sprite is set. See [fset](https://github.com/nesbox/TIC-80/wiki/fset) for more details.
	 * @param index number Sprite index
	 * @param flag number Flag index (0-7) to check
	 * @return boolean enabled
	 */
	public static function fget(index:Int, flag:SpriteFlags):Bool;

	/**
	 * Print string with font defined in foreground sprites.
	 * To simply print to the screen, check out `print`.
	 * To print to the console, check out `trace`.
	 * @param text string Any string to be printed to the screen
	 * @param x number x coordinate where to print the text
	 * @param y number y coordinate where to print the text
	 * @param colorkey number The colorkey to use as transparency.
	 * @param charWidth number Width Width of characters to use for spacing, in pixels
	 * @param charHeight number Height Height of characters to use for multiple line spacing, in pixels.
	 * @param fixed boolean A flag indicating whether to fix the width of the characters, by default is not fixed
	 * @param scale number Font scaling
	 * @return width number The width of the text in pixels.
	 */
	public static function font(text:String, x:Int, y:Int, colorkey:Int, charWidth:Int, charHeight:Int, fixed:Bool, scale:Int):Void;

	/**
	 * Each sprite has eight flags which can be used to store information or signal different conditions. For example, flag 0 might be used to indicate that the sprite is invisible, flag 6 might indicate that the flag should be draw scaled etc.
	 * See algo [fget](https://github.com/nesbox/TIC-80/wiki/fget) (0.80)
	 * @param index number Sprite index
	 * @param flag number Index of flag (0-7)
	 * @param bool boolean What state to set the flag, true or false
	 */
	public static function fset(index:Int, flag:Int, bool:Bool):Void;

	/**
	 * The function returns true if the key denoted by keycode is pressed.
	 * * 01 = A
	 * * 02 = B
	 * * 03 = C
	 * * 04 = D
	 * * 05 = E
	 * * 06 = F
	 * * 07 = G
	 * * 08 = H
	 * * 09 = I
	 * * 10 = J
	 * * 11 = K
	 * * 12 = L
	 * * 13 = M
	 * * 14 = N
	 * * 15 = O
	 * * 16 = P
	 * * 17 = Q
	 * * 18 = R
	 * * 19 = S
	 * * 20 = T
	 * * 21 = U
	 * * 22 = V
	 * * 23 = W
	 * * 24 = X
	 * * 25 = Y
	 * * 26 = Z
	 * * 27 = 0
	 * * 28 = 1
	 * * 29 = 2
	 * * 30 = 3
	 * * 31 = 4
	 * * 32 = 5
	 * * 33 = 6
	 * * 34 = 7
	 * * 35 = 8
	 * * 36 = 9
	 * * 37 = MINUS
	 * * 38 = EQUALS
	 * * 39 = LEFTBRACKET
	 * * 40 = RIGHTBRACKET
	 * * 41 = BACKSLASH
	 * * 42 = SEMICOLON
	 * * 43 = APOSTROPHE
	 * * 44 = GRAVE
	 * * 45 = COMMA
	 * * 46 = PERIOD
	 * * 47 = SLASH
	 * * 48 = SPACE
	 * * 49 = TAB
	 * * 50 = RETURN
	 * * 51 = BACKSPACE
	 * * 52 = DELETE
	 * * 53 = INSERT
	 * * 54 = PAGEUP
	 * * 55 = PAGEDOWN
	 * * 56 = HOME
	 * * 57 =: Void;
	 * * 58 = UP
	 * * 59 = DOWN
	 * * 60 = LEFT
	 * * 61 = RIGHT
	 * * 62 = CAPSLOCK
	 * * 63 = CTRL
	 * * 64 = SHIFT
	 * * 65 = ALT
	 * @param code number The key code (1..65) we want to check
	 * @return pressed boolean
	 */
	public static function key(code:Int):Bool;

	/**
	 * This function returns true if the given key is pressed but wasn't pressed in the previous frame.
	 * Refer to [btnp](https://github.com/nesbox/TIC-80/wiki/btnp) for an explanation of the optional hold and period parameters
	 * @param code number The key code we want to check (see codes [here](https://github.com/nesbox/TIC-80/wiki/key#parameters))
	 * @param hold number Time in ticks before autorepeat
	 * @param period number Time in ticks for autorepeat interval
	 * @return pressed boolean
	 */
	public static function keyp(code:Int, hold:Int, period:Int):Bool;

	/**
	 * Draws a straight line from point (x0,y0) to point (x1,y1) in the specified color.
	 * @param x0 number The x coordinate where the line starts
	 * @param y0 number The y coordinate where the line starts
	 * @param x1 number The x coordinate where the line ends
	 * @param y1 number The y coordinate where the line ends
	 * @param color ?number The index of the color in the current [palette](https://github.com/nesbox/TIC-80/wiki/palette)
	 */
	public static function line(x0:Int, y0:Int, x1:Int, y1:Int, color:Int):Void;

	/**
	 * The map consists of cells of 8x8 pixels, each of which can be filled with a sprite using the map editor. The map can be up to 240 cells wide by 136 deep. This function will draw the desired area of the map to a specified screen position. For example, map(5,5,12,10,0,0) will draw a 12x10 section of the map, starting from map co-ordinates (5,5) to screen position (0,0).
	 * The map function’s last parameter is a powerful callback function​ for changing how map cells (sprites) are drawn when map is called. It can be used to rotate, flip and replace sprites while the game is running. Unlike mset, which saves changes to the map, this special function can be used to create animated tiles or replace them completely. Some examples include changing sprites to open doorways, hiding sprites used to spawn objects in your game and even to emit the objects themselves.
	 * The tilemap is laid out sequentially in RAM - writing 1 to 0x08000 will cause tile(sprite) #1 to appear at top left when map() is called. To set the tile immediately below this we need to write to 0x08000 + 240, ie 0x080F0
	 * @param x number The leftmost map cell to be drawn.
	 * @param y number The uppermost map cell to be drawn.
	 * @param w number The number of cells to draw horizontally.
	 * @param h number The number of cells to draw vertically.
	 * @param sx number The screen x coordinate where drawing of the map section will start.
	 * @param sy number The screen y coordinate where drawing of the map section will start.
	 * @param colorkey number Index (or array of indexes 0.80.0) of the color that will be used as transparent color. Not setting this parameter will make the map opaque.
	 * @param scale number Map scaling.
	 * @param remap ?function An optional function called before every tile is drawn. Using this callback function you can show or hide tiles, create tile animations or flip/rotate tiles during the map rendering stage: `callback [tile [x y] ] -> [tile [flip [rotate] ] ]`
	 */
	public static function map(x:Int, y:Int, ?w:Int = 30, ?h:Int = 17, ?sx:Int = 0, ?sy:Int = 0, ?colorkey:Int = -1, ?scale:Int = 1):Void;

	/**
	 * This function allows you to copy a continuous block of TIC's 64k [RAM](https://github.com/nesbox/TIC-80/wiki/RAM) from one address to another. Addresses are specified are in hexadecimal format, values are decimal.
	 * @param toaddr number The address you want to write to
	 * @param fromaddr number The address you want to copy from
	 * @param len number The length of the memory block you want to copy
	 */
	public static function memcpy(toaddr:Int, fromaddr:Int, len:Int):Void;

	/**
	 * This function allows you to set a continuous block of any part of TIC's [RAM](https://github.com/nesbox/TIC-80/wiki/RAM) to the same value. The address is specified in hexadecimal format, the value in decimal.
	 * @param addr number The address of the first byte of 64k [RAM](https://github.com/nesbox/TIC-80/wiki/RAM) you want to write to
	 * @param val number The value you want to write
	 * @param len number The length of the memory block you want to set
	 */
	public static function memset(addr:Int, val:Int, len:Int):Void;

	/**
	 * Gets the sprite id at the given x and y map coordinate
	 * @param x number x coordinate on the map
	 * @param y number y coordinate on the map
	 * @return id number
	 */
	public static function mget(x:Int, y:Int):Int;

	/**
	 * This function returns the mouse coordinates and a boolean value for the state of each mouse button, with true indicating that a button is pressed.
	 * @return number x, number y, boolean left, boolean middle, boolean right, number scrollx, number scrolly
	 */
	public static function mouse():Void;

	/**
	 * This function will change the tile at the specified map coordinates. By default, changes made are only kept while the current game is running. To make permanent changes to the map, see [sync](https://github.com/nesbox/TIC-80/wiki/sync).
	 * Related:
	 * * [map](https://github.com/nesbox/TIC-80/wiki/map)
	 * * [mget](https://github.com/nesbox/TIC-80/wiki/mget)
	 * * [sync](https://github.com/nesbox/TIC-80/wiki/sync)
	 * @param x number x coordinate on the map
	 * @param y number y coordinate on the map
	 * @param id number The background tile (0-255) to place in map at specified coordinates.
	 */
	public static function mset(x:Int, y:Int, id:Int):Void;

	/**
	 * This function starts playing a track created in the [Music Editor](https://github.com/nesbox/TIC-80/wiki/Home#music-editor). Call without arguments to *stop* the music.
	 * @param track ?number The id of the track to play from (0..7)
	 * @param frame ?number The index of the frame to play from (0..15)
	 * @param row ?number The index of the row to play from (0..63)
	 * @param loop ?number Loop music or play it once (true/false)
	 * @param sustain ?number Sustain notes after the end of each frame or stop them (true/false)
	 */
	public static function music(?track:Int, ?frame:Int, ?row:Int, ?loop:Int, ?sustain:Int):Void;

	/**
	 * This function allows to read the memory from TIC.
	 * It's useful to access resources created with the integrated tools like [sprite](https://github.com/nesbox/TIC-80/wiki/sprite), maps, sounds, cartridges data? Never dream to sound a sprite?
	 * Address are in hexadecimal format but values are decimal.
	 * To write to a memory address, use [poke](https://github.com/nesbox/TIC-80/wiki/poke).
	 * @param addr number Any address of the 80k [RAM](https://github.com/nesbox/TIC-80/wiki/RAM) byte you want to read
	 * @return val number the value read from the addr parameter. Each address stores a byte, so the value will be an integer from 0 to 255.
	 */
	public static function peek(addr:Int):Int;

	/**
	 * This function enables you to read values from TIC's [RAM](https://github.com/nesbox/TIC-80/wiki/RAM). The address should be specified in hexadecimal format.
	 * @param addr4 number any address of the 80K RAM byte you want to read, divided in groups of 4 bits (nibbles). Therefore, to address the high nibble of position 0x2000 you should pass 0x4000 as addr4, and to access the low nibble (rightmost 4 bits) you would pass 0x4001.
	 * @return val4 number the 4-bit value (0-15) read from the specified address.
	 */
	public static function peek4(addr4:Int):Int;

	/**
	 * This function can read or write pixel color values. When called with a color parameter, the pixel at the specified coordinates is set to that color. Calling the function without a color parameter returns the color of the pixel at the specified position.
	 * @param x number x coordinate of the pixel to write
	 * @param y number y coordinate of the pixel to write
	 * @param color ?number The index of the color in the [palette](https://github.com/nesbox/TIC-80/wiki/palette) to apply at the desired coordinates
	 * @return color number the index (0-15) in the color [palette](https://github.com/nesbox/TIC-80/wiki/palette) at the specified x and y coordinates.
	 */
	public static function pix(x:Int, y:Int, ?color:Int):Int;

	/**
	 * This function allows you to save and retrieve data in one of the 256 individual 32-bit slots available in the cartridge's persistent memory. This is useful for saving high-scores, level advancement or achievements. The data is stored as unsigned 32-bit integers (from 0 to 4294967295).
	 * Tips:
	 * * pmem depends on the cartridge hash (md5), so don't change your lua script if you want to keep the data.
	 * * Use _saveid_: with a personalized string in the header [metadata](https://github.com/nesbox/tic.computer/wiki#cartridge-metadata) to override the default MD5 calculation. This allows the user to update a cart without losing their saved data.
	 * @param index number The index of the value you want to save/read in the persistent memory
	 * @param val number The value you want to store in the memory. Omit this parameter if you want to read the memory.
	 * @return val number When function is call with only index parameters it'll return the value saved in that memory slot.
	 */
	public static function pmem(index:Int, ?val:Int):Int;

	/**
	 * This function allows you to write a single byte to any address in TIC's [RAM](https://github.com/nesbox/TIC-80/wiki/RAM). The address should be specified in hexadecimal format, the value in decimal.
	 * @param addr number The address in [RAM](https://github.com/nesbox/TIC-80/wiki/RAM)
	 * @param val number The value to write
	 */
	public static function poke(addr:Int, val:Int):Void;

	/**
	 * This function allows you to write to the virtual [RAM](https://github.com/nesbox/TIC-80/wiki/RAM) of TIC. It differs from [poke](https://github.com/nesbox/TIC-80/wiki/poke) in that it divides memory in groups of 4 bits. Therefore, to address the high nibble of position 0x4000 you should pass 0x8000 as addr4, and to access the low nibble (rightmost 4 bits) you would pass 0x8001. The address should be specified in hexadecimal format, and values should be given in decimal.
	 * @param addr4 number the nibble (4 bits) address in RAM to which to write,
	 * @param val number the 4-bit value (0-15) to write to the specified address
	 */
	public static function poke4(addr4:Int, val:Int):Void;

	/**
	 * This will simply print text to the screen using the font defined in config. When set to true, the fixed width option ensures that each character will be printed in a 'box' of the same size, so the character 'i' will occupy the same width as the character 'w' for example. When fixed width is false, there will be a single space between each character. Refer to the [example](https://github.com/nesbox/TIC-80/wiki/print#example-1) for an illustration.
	 * * To use a custom rastered font, check out [font](https://github.com/nesbox/TIC-80/wiki/font).
	 * * To print to the console, check out [trace](https://github.com/nesbox/TIC-80/wiki/trace).
	 * @param text any string to be printed to the screen
	 * @param x ?number x coordinate where to print the text
	 * @param y ?number y coordinate where to print the text
	 * @param color ?number the color to use to draw the text to the screen
	 * @param fixed ?boolean a flag indicating whether fixed width printing is required
	 * @param scale ?number font scaling
	 * @param smallfont ?boolean use small font if true
	 * @return width number The width of the text in pixels.
	 */
	public static function print(text:String, ?x:Int, ?y:Int, ?color:Int, ?fixed:Bool, ?scale:Int, ?smallfont:Bool):Int;

	/**
	 * This function draws a filled rectangle of the desired size and color at the specified position. If you only need to draw the the border or outline of a rectangle (ie not filled) see [rectb](https://github.com/nesbox/TIC-80/wiki/rectb)
	 * @param x number x coordinate of the top left corner of the rectangle
	 * @param y number y coordinate of the top left corner of the rectangle
	 * @param w number The width the rectangle in pixels
	 * @param h number The height of the rectangle in pixels
	 * @param color number The index of the color in the [palette](https://github.com/nesbox/TIC-80/wiki/palette) that will be used to fill the rectangle
	 */
	public static function rect(x:Int, y:Int, w:Int, h:Int, color:Int):Void;

	/**
	 * This function draws a one pixel thick rectangle border at the position requested.
	 * If you need to fill the rectangle with a color, see [rect](https://github.com/nesbox/TIC-80/wiki/rect) instead.
	 * @param x number x coordinate of the top left corner of the rectangle
	 * @param y number y coordinate of the top left corner of the rectangle
	 * @param w number The width the rectangle in pixels
	 * @param h number The height of the rectangle in pixels
	 * @param color number The index of the color in the [palette](https://github.com/nesbox/TIC-80/wiki/palette) that will be used to color the rectangle's border.
	 */
	public static function rectb(x:Int, y:Int, w:Int, h:Int, color:Int):Void;

	/**
	 * Resets the cartridge. To return to the console, see the [exit](https://github.com/nesbox/TIC-80/wiki/exit) function.
	 */
	public static function reset():Void;

	/**
	 * This function will play the sound with *id* created in the sfx editor. Calling the function with id set to -1 will stop playing the channel.
	 * The **note** can be supplied as an integer between 0 and 95 (representing 8 octaves of 12 notes each) or as a string giving the note name and octave. For example, a note value of '14' will play the note 'D' in the second octave. The same note could be specified by the string 'D-2'. Note names consist of two characters, the note itself (**in upper case**) followed by '-' to represent the natural note or '#' to represent a sharp. There is no option to indicate flat values. The available note names are therefore: C-, C#, D-, D#, E-, F-, F#, G-, G#, A-, A#, B-. The octave is specified using a single digit in the range 0 to 8.
	 * The **duration** specifies how many ticks to play the sound for; since TIC-80 runs at 60 frames per second, a value of 30 represents half a second. A value of -1 will play the sound continuously.
	 * The **channel** parameter indicates which of the four channels to use. Allowed values are 0 to 3.
	 * **Volume** can be between 0 and 15.
	 * **Speed** in the range -4 to 3 can be specified and means how many 'ticks+1' to play each step, so speed==0 means 1 tick per step.
	 * @param id number The sfx id, from 0 to 63
	 * @param note ?number The note number or name
	 * @param duration ?number Duration (-1 by default)
	 * @param channel ?number Which channel to use, 0..3
	 * @param volume ?number Volume (15 by default)
	 * @param speed ?number Speed (0 by default)
	 */
	public static function sfx(id:Int, ?note:Int, ?duration:Int, ?channel:Int, ?volume:Int, ?speed:Int):Void;

	/**
	 * Draws the sprite number index at the x and y coordinate.
	 * You can specify a colorkey in the palette which will be used as the transparent color or use a value of -1 for an opaque sprite.
	 * The sprite can be scaled up by a desired factor. For example, a scale factor of 2 means an 8x8 pixel sprite is drawn to a 16x16 area of the screen.
	 * You can flip the sprite where:
	 * * 0 = No Flip
	 * * 1 = Flip horizontally
	 * * 2 = Flip vertically
	 * * 3 = Flip both vertically and horizontally
	 * When you rotate the sprite, it's rotated clockwise in 90° steps:
	 * * 0 = No rotation
	 * * 1 = 90° rotation
	 * * 2 = 180° rotation
	 * * 3 = 270° rotation
	 * You can draw a composite sprite (consisting of a rectangular region of sprites from the sprite sheet) by specifying the w and h parameters (which default to 1).
	 * @param id number Index of the sprite
	 * @param x number x coordinate where the sprite will be drawn, starting from top left corner.
	 * @param y number y coordinate where the sprite will be drawn, starting from top left corner.
	 * @param colorkey number? Index (or array of indexes) of the color in the sprite that will be used as transparent color. Use -1 if you want an opaque sprite.
	 * @param scale number? Scale factor applied to sprite.
	 * @param flip boolean? Flip the sprite vertically or horizontally or both.
	 * @param rotate number? Rotate the sprite by 0, 90, 180 or 270 degrees.
	 * @param w number? Width of composite sprite
	 * @param h number? Height of composite sprite
	 */
	public static function spr(sprite_num:Int, x:Int, y:Int, ?colorkey:Int = -1, ?scale:Int = 1, ?flip:Int = 0, ?rotate:Int = 0, ?w:Int = 1, ?h:Int = 1):Void;

	/**
	 * The pro version of TIC-80 contains 8 memory banks. To switch between these banks, sync can be used to either load contents from a memory bank to runtime, or save contents from the active runtime to a bank. The function can only be called once per frame.
	 * If you have manipulated the runtime memory (e.g. by using mset), you can reset the active state by calling sync(0,0,false). This resets the whole runtime memory to the contents of bank 0.
	 * Note that sync is not used to load code from banks; this is done automatically.
	 * @param mask number Mask of sections you want to switch. See [here](https://github.com/nesbox/TIC-80/wiki/sync#parameters)
	 * @param bank number memory bank, can be 0...7.
	 * @param toCart boolean if `true`, save sprites/map/sound from runtime to bank, if `false` load data from bank to runtime.
	 */
	public static function sync(mask:Int, bank:Int, toCart:Bool):Void;

	/**
	 * This function returns the number of milliseconds elapsed since the cartridge began execution. Useful for keeping track of time, animating items and triggering events.
	 * @return ticks number The number of milliseconds elapsed since the application began.
	 */
	public static function time():Int;

	/**
	 * This function returns the number of seconds elapsed since January 1st, 1970. Useful for creating persistent games which evolve over time between plays.
	 * @return seconds number The number of seconds that have passed since January 1st, 1970.
	 */
	public static function tstamp():Int;

	/**
	 * This is a service function, useful for debugging your code. It prints the message parameter to the console in the (optional) color specified.
	 * Tips:
	 * 1. The Lua concatenator for strings is .. (two points)
	 * 1. Use console cls command to clear the output from trace
	 * @param msg string The message to print in the console. Can be a 'string' or variable.
	 * @param color ?number Color for the msg text
	 */
	public static function trace(msg:String, ?color:Int):Void;

	/**
	 * This function draws a triangle filled with color, using the supplied vertices.
	 * @param x1 number x coordinate of the first triangle corner
	 * @param y1 number y coordinate of the first triangle corner
	 * @param x2 number x coordinate of the second triangle corner
	 * @param y2 number y coordinate of the second triangle corner
	 * @param x3 number x coordinate of the third triangle corner
	 * @param y3 number y coordinate of the third triangle corner
	 * @param color number The index of the desired color in the current [palette](https://github.com/nesbox/TIC-80/wiki/palette)
	 */
	public static function tri(x1:Int, y1:Int, x1:Int, y2:Int, x3:Int, y3:Int, color:Int):Void;

	/**
	 * It renders a triangle filled with texture from image ram or map ram
	 * **Use in 3D graphics**
	 * This function does not perform perspective correction, so it is not generally suitable for 3D graphics (except in some constrained scenarios). In particular, if the vertices in the triangle have different 3D depth, you may see some distortion.
	 * These can be thought of as the window inside image ram (sprite sheet), or map ram. Note that the sprite sheet or map in this case is treated as a single large image, with U and V addressing its pixels directly, rather than by sprite ID. So for example the top left corner of sprite #2 would be located at u=16, v=0.
	 * * **u1**: the U coordinate of the first triangle corner
	 * * **v1**: the V coordinate of the first triangle corner
	 * * **u2**: the U coordinate of the second triangle corner
	 * * **v2**: the V coordinate of the second triangle corner
	 * * **u3**: the U coordinate of the third triangle corner
	 * * **v3**: the V coordinate of the third triangle corner
	 * * **use_map**: if false (default), the triangle's texture is read from the image vram (sprite sheet). If true, the texture comes from the map ram.
	 * * **colorkey**: index (or array of indexes 0.80.0) of the color that will be used as transparent color.
	 * @param x1 number The x coordinate of the first triangle corner
	 * @param y1 number The y coordinate of the first triangle corner
	 * @param x2 number The x coordinate of the second triangle corner
	 * @param y2 number The y coordinate of the second triangle corner
	 * @param x3 number The x coordinate of the third triangle corner
	 * @param y3 number The y coordinate of the third triangle corner
	 * @param u1 number The U coordinate of the first triangle corner
	 * @param v1 number The V coordinate of the first triangle corner
	 * @param u2 number The U coordinate of the second triangle corner
	 * @param v2 number The V coordinate of the second triangle corner
	 * @param u3 number The U coordinate of the third triangle corner
	 * @param v3 number The V coordinate of the third triangle corner
	 * @param use_map ?boolean if false (default), the triangle's texture is read from the image vram (sprite sheet). If true, the texture comes from the map ram.
	 * @param colorkey ?number index (or array of indexes 0.80.0) of the color that will be used as transparent color.
	 */
	public static function textri(x1:Int, y1:Int, x1:Int, y2:Int, x3:Int, y3:Int, u1:Int, v1:Int, u2:Int, v2:Int, u3:Int, v3:Int, ?use_ma:Bool,
		?colorkey:Int):Void;
}
