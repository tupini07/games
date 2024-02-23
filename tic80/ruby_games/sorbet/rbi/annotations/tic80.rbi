# typed: true

# TIC-80 version: 1.1.2837 (https://github.com/nesbox/TIC-80/tree/v1.1.2837)

# The BDR function allows you to execute code between the rendering of each scan line. This is primarily used to manipulate the palette, making it possible to use a different palette for each scan line, and therefore more than 16 colors at a time.
# @param scanline [Integer] The scan line about to be drawn (0..143).
sig { params(scanline: Integer).void }
def BDR(scanline); end

# The BOOT function is called once when your cartridge is booted. It should be used for startup/initialization code. For scripting languages that allow code in the global scope (like Lua), using BOOT is preferred rather than including source code in the global scope.
sig { void }
def BOOT; end

# The TIC function is the 'main' update/draw callback and must be present in every program. It takes no parameters and is called sixty times per second (60fps).
sig { void }
def TIC; end

# The OVR function is the final step in rendering a frame. It draws on a separate layer and can be used together with BDR to create separate background or foreground layers and other visual effects. Since OVR() happens after all the scanline callbacks, it can be used to draw sprites with a static palette (even if BDR() is otherwise changing the palette on each line).
sig { void }
def OVR; end

# The MENU function is a callback that handles Game Menu items defined using the -- menu: ITEM1 ITEM2 ITEM3 metatag. Note that MENU indexing starts at 0. The Game Menu is a sub-menu of the TIC-80 Menu. You cannot edit permanent memory with pmem from the MENU callback. Set a temporary variable instead and do the pmem calls inside TIC.
# @param i [Integer] The index of the menu item.
sig { params(i: Integer).void }
def MENU(i); end

# This function allows you to read the status of TIC's controller buttons. It returns true if the button with the supplied id is currently in the pressed state and remains true for as long as the button is held down. To see if a button was just pressed, use btnp instead.
# @param id [Integer] id (0..31) of the key we want to interrogate (see the key map for reference or type help buttons in console).
# @return [T::Boolean] button is pressed (true/false)
sig do
  params(
    id: Integer
  ).returns(T::Boolean)
end
def btn(id); end

# @param id [Integer] id (0..31) of the key we want to interrogate (see the key map for reference or type help buttons in console).
# @param hold [Integer] the time (in ticks) the button must be pressed before re-checking
# @param period [Integer] the amount of time (in ticks) after hold before this function will return true again.
# @return [T::Boolean] button is pressed now but not in previous frame (true/false)
sig do
  params(
    id: Integer,
    hold: T.nilable(Integer),
    period: T.nilable(Integer)
  ).returns(T::Boolean)
end
def btnp(id, hold, period); end

# This function clears/fills the entire screen using color. If no parameter is passed, index 0 of the palette is used.
# The function is often called inside TIC(), clearing the screen before each frame, but this is not mandatory. If you're drawing to the entire screen each frame (for example with sprites, the map or primitive shapes) there is no need to clear the screen beforehand however it can result in annoying artifacts.
# Tip: You can create some interesting effects by not calling cls(), allowing frames to stack on top of each other - or using it repeatedly to "flash" the screen when some special event occurs.
# @param color [Integer] index (0..15) of a color in the current palette (defaults to 0)
sig do
  params(
    color: Integer
  ).void
end
def cls(color = 0); end

# This function draws a filled circle of the desired radius and color with its center at x, y. It uses the Bresenham algorithm.
# @param x [Integer] the x-coordinate of the circle's center
# @param y [Integer] the y-coordinate of the circle's center
# @param radius [Integer] the radius of the circle in pixels
# @param color [Integer] the index of the desired color in the current palette
sig do
  params(
    x: Integer,
    y: Integer,
    radius: Integer,
    color: Integer
  ).void
end
def circ(x, y, radius, color); end

# Draws the circumference of a circle with its center at x, y using the radius and color requested. It uses the Bresenham algorithm.
# @param x [Integer] the x-coordinate of the circle's center
# @param y [Integer] the y-coordinate of the circle's center
# @param radius [Integer] the radius of the circle in pixels
# @param color [Integer] the index of the desired color in the current palette
sig do
  params(
    x: Integer,
    y: Integer,
    radius: Integer,
    color: Integer
  ).void
end
def circb(x, y, radius, color); end

# This function limits drawing to a clipping region or 'viewport' defined by x,y, width, and height. Any pixels falling outside of this area will not be drawn.
# Calling clip() with no parameters will reset the drawing area to the entire screen.
# @param x [T.nilable(Integer)] the x-coordinate of the top left of the clipping region
# @param y [T.nilable(Integer)] the y-coordinate of the top left of the clipping region
# @param width [T.nilable(Integer)] the width of the clipping region in pixels
# @param height [T.nilable(Integer)] the height of the clipping region in pixels
sig do
  params(
    x: T.nilable(Integer),
    y: T.nilable(Integer),
    width: T.nilable(Integer),
    height: T.nilable(Integer)
  ).void
end
def clip(x = nil, y = nil, width = nil, height = nil); end

# This function draws a filled ellipse centered at x, y using palette index color and radii a and b. It uses the Bresenham algorithm.
# @param x [Integer] the x-coordinate of the ellipse's center
# @param y [Integer] the y-coordinate of the ellipse's center
# @param a [Integer] the horizontal radius of the ellipse in pixels
# @param b [Integer] the vertical radius of the ellipse in pixels
# @param color [Integer] the index of the desired color in the current palette
sig do
  params(
    x: Integer,
    y: Integer,
    a: Integer,
    b: Integer,
    color: Integer
  ).void
end
def elli(x, y, a, b, color); end

# This function draws an ellipse border with the radiuses a b and color with its center at x, y. It uses the Bresenham algorithm.
# @param x [Integer] the x-coordinate of the ellipse's center
# @param y [Integer] the y-coordinate of the ellipse's center
# @param a [Integer] the horizontal radius of the ellipse in pixels
# @param b [Integer] the vertical radius of the ellipse in pixels
# @param color [Integer] the index of the desired color in the current palette
sig do
  params(
    x: Integer,
    y: Integer,
    a: Integer,
    b: Integer,
    color: Integer
  ).void
end
def ellib(x, y, a, b, color); end

# This function causes program execution to be terminated after the current TIC function ends. The entire function is executed, including any code that follows exit(). When the program ends you are returned to the console.
sig { void.void }
def exit; end

# Returns true if the specified flag of the sprite is set. Each sprite has eight flags which can be used to store information or signal different conditions. For example, flag 0 might be used to indicate that the sprite is invisible, flag 6 might indicate that the sprite should be drawn scaled etc.
# @param sprite_id [Integer] sprite index (0..511)
# @param flag [Integer] flag index to check (0..7)
# @return [Boolean] whether the flag was set (true/false)
sig do
  params(
    sprite_id: Integer,
    flag: Integer
  ).returns(T::Boolean)
end
def fget(sprite_id, flag); end

# This function sets the sprite flag to a given boolean value. Each sprite has eight flags which can be used to store information or signal different conditions. For example, flag 0 might be used to indicate that the sprite is invisible, flag 6 might indicate that the sprite should be drawn scaled etc.
# @param sprite_id [Integer] sprite index (0..511)
# @param flag [Integer] index of flag (0-7) to set
# @param bool [Boolean] state to set (true/false)
sig do
  params(
    sprite_id: Integer,
    flag: Integer,
    bool: T::Boolean
  ).void
end
def fset(sprite_id, flag, bool); end

# This function will draw text to the screen using the foreground spritesheet as the font. Sprite #256 is used for ASCII code 0, #257 for code 1 and so on. The character 'A' has the ASCII code 65 so will be drawn using the sprite with sprite #321 (256+65).
# @param text [String] The string to be printed.
# @param x [Integer] x-coordinate of print position.
# @param y [Integer] y-coordinate of print position.
# @param transcolor [T.nilable(Integer)] The palette index to use for transparency.
# @param char_width [T.nilable(Integer)] Distance between start of each character, in pixels.
# @param char_height [T.nilable(Integer)] Distance vertically between start of each character, in pixels, when printing multi-line text.
# @param fixed [T.nilable(Boolean)] Indicates whether the font is fixed width (defaults to false ie variable width).
# @param scale [T.nilable(Integer)] Font scaling (defaults to 1).
# @param alt [T.nilable(Boolean)] If set to true, the second 128 foreground tiles (#384–511) are used for the font rather than the first 128 (#256-383) as if set to false.
# @return [Integer] Returns the width of the rendered text in pixels.
sig do
  params(
    text: String,
    x: Integer,
    y: Integer,
    transcolor: T.nilable(Integer),
    char_width: T.nilable(Integer),
    char_height: T.nilable(Integer),
    fixed: T.nilable(T::Boolean),
    scale: T.nilable(Integer),
    alt: T.nilable(T::Boolean)
  ).returns(Integer)
end
def font(text, x, y, transcolor = nil, char_width = nil, char_height = nil, fixed = false, scale = 1, alt = false); end

# This function checks if a specific key or any key is currently pressed.
# @param code [T.nilable(Integer)] the key code to check (1..65), see the table below or type help keys in console.
# @return [T::Boolean] a Boolean value which indicates whether or not the specified key is currently pressed. If no keycode is specified, returns a Boolean value indicating if any key is pressed.
sig { params(code: T.nilable(Integer)).returns(T::Boolean) }
def key(code = nil); end

# This function returns true if the given key is pressed but wasn't pressed in the previous frame. If no keycode is specified, it will return true if any key is pressed but wasn't in the previous frame. Refer to btnp for an explanation of the optional hold and period parameters.
# @param code [T.nilable(Integer)] the key code we want to check (1..65) (see codes here)
# @param hold [T.nilable(Integer)] time in ticks before autorepeat
# @param period [T.nilable(Integer)] time in ticks for autorepeat interval
# @return [T::Boolean] key is pressed (true/false)
sig do
  params(
    code: T.nilable(Integer),
    hold: T.nilable(Integer),
    period: T.nilable(Integer)
  ).returns(T::Boolean)
end
def keyp(code = nil, hold = nil, period = nil); end

# Draws a straight line from point (x0,y0) to point (x1,y1) in the specified color.
# @param x0 [Integer] the x-coordinate of the start of the line
# @param y0 [Integer] the y-coordinate of the start of the line
# @param x1 [Integer] the x-coordinate of the end of the line
# @param y1 [Integer] the y-coordinate of the end of the line
# @param color [Integer] the index of the color in the current palette
sig do
  params(
    x0: Integer,
    y0: Integer,
    x1: Integer,
    y1: Integer,
    color: Integer
  ).void
end
def line(x0, y0, x1, y1, color); end

# The map consists of cells of 8x8 pixels, each of which can be filled with a tile using the map editor.
# The map can be up to 240 cells wide by 136 deep. This function will draw the desired area of the map to a specified screen position. For example, map(5,5,12,10,0,0) will draw a 12x10 section of the map, starting from map co-ordinates (5,5) to screen position (0,0). map() without any parameters will draw a 30x17 map section (a full screen) to screen position (0,0).
# The map function’s last parameter is a powerful callback function​ for changing how each cells is drawn. It can be used to rotate, flip or even replace tiles entirely. Unlike mset, which saves changes to the map, this special function can be used to create animated tiles or replace them completely. Some examples include changing tiles to open doorways, hiding tiles used only to spawn objects in your game and even to emit the objects themselves.
# The tilemap is laid out sequentially in RAM - writing 1 to 0x08000 will cause tile #1 to appear at top left when map is called. To set the tile immediately below this we need to write to 0x08000 + 240, ie 0x080F0
# @param x [T.nilable(Integer)] The x-coordinate of the top left map cell to be drawn.
# @param y [T.nilable(Integer)] The y-coordinate of the top left map cell to be drawn.
# @param w [T.nilable(Integer)] The number of cells to draw horizontally.
# @param h [T.nilable(Integer)] The number of cells to draw vertically.
# @param sx [T.nilable(Integer)] The screen x-coordinate where drawing of the map section will start.
# @param sy [T.nilable(Integer)] The screen y-coordinate where drawing of the map section will start.
# @param colorkey [T.nilable(Integer)] index (or array of indexes 0.80.0) of the color that will be used as transparent color. Not setting this parameter will make the map opaque.
# @param scale [T.nilable(Integer)] Map scaling.
# @param remap [T.nilable(T.proc.params(tile: Integer, x: Integer, y: Integer).returns(T::Array[Integer]))] An optional function called before every tile is drawn. Using this callback function you can show or hide tiles, create tile animations or flip/rotate tiles during the map rendering stage: callback [tile [x y] ] -> [tile [flip [rotate] ] ]
sig do
  params(
    x: T.nilable(Integer),
    y: T.nilable(Integer),
    w: T.nilable(Integer),
    h: T.nilable(Integer),
    sx: T.nilable(Integer),
    sy: T.nilable(Integer),
    colorkey: T.nilable(Integer),
    scale: T.nilable(Integer),
    remap: T.nilable(T.proc.params(tile: Integer, x: Integer, y: Integer).returns(T::Array[Integer]))
  ).void
end
def map(x = 0, y = 0, w = 30, h = 17, sx = 0, sy = 0, colorkey = -1, scale = 1, remap = nil); end

# This function copies a continuous block of RAM from one address to another. Addresses are specified in hexadecimal format, values are decimal.
# @param to [Integer] the address you want to write to
# @param from [Integer] the address you want to copy from
# @param length [Integer] the length of the memory block you want to copy (in bytes)
sig { params(to: Integer, from: Integer, length: Integer).void }
def memcpy(to, from, length); end

# This function sets a continuous block of RAM to the same value. The address is specified in hexadecimal format, the value in decimal.
# @param addr [Integer] the address of the first byte of RAM you want to write to
# @param value [Integer] the value you want to write (0..255)
# @param length [Integer] the length of the memory block you want to set
sig { params(addr: Integer, value: Integer, length: Integer).void }
def memset(addr, value, length); end

# This function returns the index of the tile at the specified map coordinates, the top left cell of the map being (0, 0).
# @param x [Integer] The x-coordinate of the map cell.
# @param y [Integer] The y-coordinate of the map cell.
# @return [Integer] The index of the tile at the specified map coordinates.
sig { params(x: Integer, y: Integer).returns(Integer) }
def mget(x, y); end

# This function writes the specified background tile tile_id into the map at the given position. By default, changes to the map are lost when execution ends but they can be made permanent using sync.
# @param x [Integer] The x-coordinate of the map cell.
# @param y [Integer] The y-coordinate of the map cell.
# @param tile_id [Integer] The index of the tile (0-255).
sig { params(x: Integer, y: Integer, tile_id: Integer).void }
def mset(x, y, tile_id); end

# This function returns the mouse coordinates, a boolean value for the state of each mouse button (with true indicating that a button is pressed) and any change in the scroll wheel. Note that scrollx values are only returned for devices with a second scroll wheel, trackball etc.
# @return [T::Array[T.any(Integer, T::Boolean)]] An array containing the x and y coordinates of the mouse pointer, boolean values indicating whether the left, middle, and right buttons are down, and the x and y scroll deltas since the last frame.
sig { returns(T::Array[T.any(Integer, T::Boolean)]) }
def mouse(); end

# This function starts playing a track created in the Music Editor.
# @param track [T.nilable(Integer)] The id of the track to play (0..7).
# @param frame [T.nilable(Integer)] The index of the frame to play from (0..15).
# @param row [T.nilable(Integer)] The index of the row to play from (0..63).
# @param loop [T.nilable(T::Boolean)] Loop music (true) or play it once (false).
# @param sustain [T.nilable(T::Boolean)] Sustain notes after the end of each frame or stop them (true/false).
# @param tempo [T.nilable(Integer)] Play track with the specified tempo, (added in version 0.90).
# @param speed [T.nilable(Integer)] Play track with the specified speed, (added in version 0.90).
sig do
  params(
    track: T.nilable(Integer),
    frame: T.nilable(Integer),
    row: T.nilable(Integer),
    loop: T.nilable(T::Boolean),
    sustain: T.nilable(T::Boolean),
    tempo: T.nilable(Integer),
    speed: T.nilable(Integer)
  ).void
end
def music(track = -1, frame = -1, row = -1, loop = true, sustain = false, tempo = -1, speed = -1); end

# The peek function allows you to read directly from RAM. It can be used to access resources created with the integrated tools, such as the sprite, map and sound editors, as well as cartridge data.
# @param addr [Integer] The address of RAM you desire to read.
# @param bits [Integer] The number of bits to read (1, 2, 4, or 8) from address (default: 8).
# @return [Integer] The range of value returned depends on the bits parameter.
sig { params(addr: Integer, bits: Integer).returns(Integer) }
def peek(addr, bits = 8); end

# The peek4 function reads a nibble (4 bits) from the specified address in RAM.
# @param addr4 [Integer] The address of RAM you desire to read.
# @return [Integer] A nibble (4 bits) (0..15).
sig { params(addr4: Integer).returns(Integer) }
def peek4(addr4); end

# The peek2 function reads two bits from the specified address in RAM.
# @param addr2 [Integer] The address of RAM you desire to read.
# @return [Integer] Two bits (0..3).
sig { params(addr2: Integer).returns(Integer) }
def peek2(addr2); end

# The peek1 function reads a single bit from the specified address in RAM.
# @param bitaddr [Integer] The address of RAM you desire to read.
# @return [Integer] A single bit (0..1).
sig { params(bitaddr: Integer).returns(Integer) }
def peek1(bitaddr); end

# This function can read or write individual pixel color values. When called with a color argument, the pixel at the specified coordinates is set to that color. When called with only x y arguments, the color of the pixel at the specified coordinates is returned.
# @param x [Integer] The x-coordinate of the pixel.
# @param y [Integer] The y-coordinate of the pixel.
# @param color [T.nilable(Integer)] The index of the palette color to draw.
# @return [T.nilable(Integer)] The index (0-15) of the palette color at the specified coordinates.
sig { params(x: Integer, y: Integer, color: T.nilable(Integer)).returns(T.nilable(Integer)) }
def pix(x, y, color = nil); end

# The name "pmem" means persistent memory. This function allows you to save and retrieve data in one of the 256 individual 32-bit slots available in the cartridge's persistent memory. This is useful for saving high-scores, level advancement or achievements. Data is stored as unsigned 32-bit integer (i.e. in the range 0 to 4294967295).
# When writing a new value, the previous value is returned.
# @param index [Integer] An index (0..255) into the persistent memory of a cartridge.
# @param val32 [T.nilable(Integer)] The 32-bit integer value you want to store. Omit this parameter to read vs write.
# @return [Integer] The current/prior value saved to the specified memory slot.
sig { params(index: Integer, val32: T.nilable(Integer)).returns(Integer) }
def pmem(index, val32 = nil); end

# The poke function allows you to write directly to RAM. The requested number of bits is written at the address requested. The address is typically specified in hexadecimal format.
# @param addr [Integer] The address of RAM you desire to write.
# @param val [Integer] The integer value to write to RAM.
# @param bits [Integer] The number of bits to write (1, 2, 4, or 8; default: 8).
sig { params(addr: Integer, val: Integer, bits: Integer).void }
def poke(addr, val, bits = 8); end

# The poke4 function writes a nibble (4 bits) to the specified address in RAM.
# @param addr4 [Integer] The address of RAM you desire to write.
# @param val4 [Integer] The integer value to write to RAM.
sig { params(addr4: Integer, val4: Integer).void }
def poke4(addr4, val4); end

# The poke2 function writes two bits to the specified address in RAM.
# @param addr2 [Integer] The address of RAM you desire to write.
# @param val2 [Integer] The integer value to write to RAM.
sig { params(addr2: Integer, val2: Integer).void }
def poke2(addr2, val2); end

# The poke1 function writes a single bit to the specified address in RAM.
# @param bitaddr [Integer] The address of RAM you desire to write.
# @param bitval [Integer] The integer value to write to RAM.
sig { params(bitaddr: Integer, bitval: Integer).void }
def poke1(bitaddr, bitval); end

# This will simply print text to the screen using the font defined in config. When set to true, the fixed width option ensures that each character will be printed in a 'box' of the same size, so the character 'i' will occupy the same width as the character 'w' for example. When fixed width is false, there will be a single space between each character. Refer to the example for an illustration.
# @param text [String] any string to be printed to the screen
# @param x [Integer] x-coordinate for printing the text (default: 0)
# @param y [Integer] y-coordinate for printing the text (default: 0)
# @param color [Integer] the color to use to draw the text to the screen (default: 15)
# @param fixed [Boolean] a flag indicating whether fixed width printing is required (default: false)
# @param scale [Integer] font scaling (default: 1)
# @param smallfont [Boolean] use small font if true (default: false)
# @return [Integer] returns the width of the text in pixels.
sig do
  params(
    text: String,
    x: Integer,
    y: Integer,
    color: Integer,
    fixed: T::Boolean,
    scale: Integer,
    smallfont: T::Boolean
  ).returns(Integer)
end
def print(text, x = 0, y = 0, color = 15, fixed = false, scale = 1, smallfont = false); end

# This function draws a filled rectangle at the specified position.
# @param x [Integer] The x-coordinate of the top left corner of the rectangle.
# @param y [Integer] The y-coordinate of the top left corner of the rectangle.
# @param width [Integer] The width the rectangle in pixels.
# @param height [Integer] The height of the rectangle in pixels.
# @param color [Integer] The index of the color in the palette that will be used to fill the rectangle.
sig { params(x: Integer, y: Integer, width: Integer, height: Integer, color: Integer).void }
def rect(x, y, width, height, color); end

# This function draws a one pixel thick rectangle border.
# @param x [Integer] The x-coordinate of the top left corner of the rectangle.
# @param y [Integer] The y-coordinate of the top left corner of the rectangle.
# @param width [Integer] The width the rectangle in pixels.
# @param height [Integer] The height of the rectangle in pixels.
# @param color [Integer] The index of the color in the palette that will be used to color the rectangle's border.
sig { params(x: Integer, y: Integer, width: Integer, height: Integer, color: Integer).void }
def rectb(x, y, width, height, color); end

# Resets the TIC virtual "hardware" and immediately restarts the cartridge.
# To simply return to the console, please use exit.
sig { void }
def reset(); end

# The sfx function is used to play a sound effect created in the SFX Editor. You can specify the sound effect id, note, duration, channel, volume, and speed. To stop playing a sound effect, call the function with an id of -1.
# @param id [Integer] The id of the sound effect (0..63) or -1 to stop playing.
# @param note [T.nilable(T.any(Integer, String))] The note number or name or -1 to play the last note assigned in the SFX Editor.
# @param duration [T.nilable(Integer)] The duration (number of frames) or -1 to play continuously.
# @param channel [T.nilable(Integer)] The audio channel to use (0..3).
# @param volume [T.nilable(Integer)] The volume (0..15).
# @param speed [T.nilable(Integer)] The speed (-4..3).
sig do
  params(
    id: Integer,
    note: T.nilable(T.any(Integer, String)),
    duration: T.nilable(Integer),
    channel: T.nilable(Integer),
    volume: T.nilable(Integer),
    speed: T.nilable(Integer)
  ).void
end
def sfx(id, note = -1, duration = -1, channel = 0, volume = 15, speed = 0); end

# The spr function is used to draw a sprite at a specified x and y coordinate. You can specify the sprite id, colorkey, scale, flip, rotation, and the width and height of a composite sprite.
# @param id [Integer] The index of the sprite (0..511).
# @param x [Integer] The x-coordinate of the top left corner of the sprite.
# @param y [Integer] The y-coordinate of the top left corner of the sprite.
# @param colorkey [T.nilable(T.any(Integer, T::Array[Integer]))] The index (or array of indexes) of the color in the sprite that will be used as transparent color. Use -1 for an opaque sprite.
# @param scale [T.nilable(Integer)] The scale factor applied to the sprite.
# @param flip [T.nilable(Integer)] Flip the sprite vertically or horizontally or both.
# @param rotate [T.nilable(Integer)] Rotate the sprite by 0, 90, 180 or 270 degrees.
# @param w [T.nilable(Integer)] The width of the composite sprite.
# @param h [T.nilable(Integer)] The height of the composite sprite.
sig do
  params(
    id: Integer,
    x: Integer,
    y: Integer,
    colorkey: T.nilable(T.any(Integer, T::Array[Integer])),
    scale: T.nilable(Integer),
    flip: T.nilable(Integer),
    rotate: T.nilable(Integer),
    w: T.nilable(Integer),
    h: T.nilable(Integer)
  ).void
end
def spr(id, x, y, colorkey = -1, scale = 1, flip = 0, rotate = 0, w = 1, h = 1); end

# The sync function is used to switch between memory banks in the PRO version of TIC-80. It can be used to load contents from a memory bank to runtime, or save contents from the active runtime to a bank. The function can only be called once per frame.
# @param mask [T.nilable(Integer)] The mask of sections you want to switch. For example, 1 for tiles, 2 for sprites, 4 for map, 8 for sfx, 16 for music, 32 for palette, 64 for flags, 128 for screen. 0 will switch all the sections.
# @param bank [T.nilable(Integer)] The memory bank (0..7).
# @param tocart [T.nilable(Boolean)] True to save memory from runtime to bank/cartridge, false to load data from bank/cartridge to runtime.
sig do
  params(
    mask: T.nilable(Integer),
    bank: T.nilable(Integer),
    tocart: T.nilable(T::Boolean)
  ).void
end
def sync(mask = 0, bank = 0, tocart = false); end

# The ttri function is used to draw a triangle filled with texture from either SPRITES or MAP RAM or VBANK.
# @param x1 [Integer] The x-coordinate of the first corner.
# @param y1 [Integer] The y-coordinate of the first corner.
# @param x2 [Integer] The x-coordinate of the second corner.
# @param y2 [Integer] The y-coordinate of the second corner.
# @param x3 [Integer] The x-coordinate of the third corner.
# @param y3 [Integer] The y-coordinate of the third corner.
# @param u1 [Integer] The U coordinate of the first corner.
# @param v1 [Integer] The V coordinate of the first corner.
# @param u2 [Integer] The U coordinate of the second corner.
# @param v2 [Integer] The V coordinate of the second corner.
# @param u3 [Integer] The U coordinate of the third corner.
# @param v3 [Integer] The V coordinate of the third corner.
# @param texsrc [T.nilable(Integer)] If 0 (default), the triangle's texture is read from SPRITES RAM. If 1, the texture comes from the MAP RAM. If 2, the texture comes from the screen RAM in the next VBANK.
# @param chromakey [T.nilable(T.any(Integer, T::Array[Integer]))] The index (or array of indexes) of the color(s) that will be used as transparent.
# @param z1 [T.nilable(Integer)] The depth parameter for texture correction of the first corner.
# @param z2 [T.nilable(Integer)] The depth parameter for texture correction of the second corner.
# @param z3 [T.nilable(Integer)] The depth parameter for texture correction of the third corner.
sig do
  params(
    x1: Integer,
    y1: Integer,
    x2: Integer,
    y2: Integer,
    x3: Integer,
    y3: Integer,
    u1: Integer,
    v1: Integer,
    u2: Integer,
    v2: Integer,
    u3: Integer,
    v3: Integer,
    texsrc: T.nilable(Integer),
    chromakey: T.nilable(T.any(Integer, T::Array[Integer])),
    z1: T.nilable(Integer),
    z2: T.nilable(Integer),
    z3: T.nilable(Integer)
  ).void
end
def ttri(x1, y1, x2, y2, x3, y3, u1, v1, u2, v2, u3, v3, texsrc = 0, chromakey = -1, z1 = 0, z2 = 0, z3 = 0); end

# The time function is used to retrieve the number of milliseconds that have passed since the game started.
# @return [Integer] The number of milliseconds that have passed since the game started.
sig { returns(Integer) }
def time; end

# The trace function is a service function, useful for debugging. It prints the supplied string or variable to the console in the (optional) color specified.
# @param message [String] The string to print.
# @param color [T.nilable(Integer)] A color index (0..15).
sig do
  params(
    message: String,
    color: T.nilable(Integer)
  ).void
end
def trace(message, color = 15); end

# The tri function is used to draw a triangle filled with color, using the supplied vertices.
# @param x1 [Integer] The x-coordinate of the first corner.
# @param y1 [Integer] The y-coordinate of the first corner.
# @param x2 [Integer] The x-coordinate of the second corner.
# @param y2 [Integer] The y-coordinate of the second corner.
# @param x3 [Integer] The x-coordinate of the third corner.
# @param y3 [Integer] The y-coordinate of the third corner.
# @param color [Integer] The index of the desired color in the current palette.
sig do
  params(
    x1: Integer,
    y1: Integer,
    x2: Integer,
    y2: Integer,
    x3: Integer,
    y3: Integer,
    color: Integer
  ).void
end
def tri(x1, y1, x2, y2, x3, y3, color); end

# The trib function is used to draw a triangle border with color, using the supplied vertices.
# @param x1 [Integer] The x-coordinate of the first corner.
# @param y1 [Integer] The y-coordinate of the first corner.
# @param x2 [Integer] The x-coordinate of the second corner.
# @param y2 [Integer] The y-coordinate of the second corner.
# @param x3 [Integer] The x-coordinate of the third corner.
# @param y3 [Integer] The y-coordinate of the third corner.
# @param color [Integer] The index of the desired color in the current palette.
sig do
  params(
    x1: Integer,
    y1: Integer,
    x2: Integer,
    y2: Integer,
    x3: Integer,
    y3: Integer,
    color: Integer
  ).void
end
def trib(x1, y1, x2, y2, x3, y3, color); end

# The tstamp function is used to retrieve the current Unix timestamp in seconds.
# @return [Integer] The current Unix timestamp in seconds.
sig { returns(Integer) }
def tstamp; end

# The vbank function is used to switch between banks 0 and 1 of VRAM. This is most commonly used for layering effects.
# @param id [Integer] The VRAM bank ID to switch to (0 or 1).
sig { params(id: Integer).void }
def vbank(id); end
