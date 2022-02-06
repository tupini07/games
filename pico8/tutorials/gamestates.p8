pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
function _init () menu_init() end

function menu_init()
	_update = menu_update
	_draw = menu_draw
end

function menu_update()
	if (btnp(🅾️)) game_init()
end

function menu_draw()
	cls()
	print("menu!", 32, 27)
	print("press 🅾️ to start game",
						  32, 59)
end
-->8
function game_init()
	_update = game_update
	_draw = game_draw
end

function game_update()
	if (btnp(🅾️)) gameover_init()
end

function game_draw()
	cls(3)
	print("game state!", 32, 32)
	print("press 🅾️ to go to game over",
	 						1, 40)
	print("state", 1, 48)
end
-->8
function gameover_init()
	_draw = gameover_draw
	_update = gameover_update
end

function gameover_draw()
	cls(8)
	print("gameover state!", 32, 32)
	print("press 🅾️ to go back to menu",
	 8, 40)
end

function gameover_update()
	if (btnp(🅾️)) menu_init()
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000