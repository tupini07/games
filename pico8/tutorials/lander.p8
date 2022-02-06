pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
--pico lander
--by dadum

function _init()
	gravity=0.025
	stars_seed=rnd(1000)

	game_over=false
	win=false

	make_player()
	make_ground()
end

function _update()
	if (not game_over) then
		move_player()
		check_land()
	else 
		if (btnp(❎)) _init()
	end
end

function _draw()
	cls()
	draw_stars()
	draw_ground()
	draw_player()
	
	if (game_over) then
		if (win) then
			print("you win!",48,48,11)
		else
			print("too bad!",48,48,8)
		end
		print("press ❎ to play again",
					   20,70,5)
	end
end
-->8
function make_player()
	player = {
		x=60,y=8,
		dx=0,dy=0,
		sprite=1,
		alive=true,
		thrust=0.075
	}
end

function draw_player()
	local sprite
	
	if (game_over and not win) then
		sprite = 5
	else 
		sprite = player.sprite
	end
	
	spr(sprite,
	    player.x,
	    player.y)

	if (game_over and win) then
		spr(4, player.x, player.y-8)
	end
	
	if (not game_over) then
		if (btn(⬆️)) then
			spr(6, player.x, player.y+8)
		end
		
		if (btn(➡️)) then
			spr(7,player.x-8,player.y)
		end
		
		if (btn(⬅️)) then
			spr(7, player.x+8,player.y,
							1,1,true)
		end
	end
end

function move_player()
	player.dy += gravity
	
	thrust()
	
	player.x += player.dx
	player.y += player.dy
	
	stay_on_screen()
end

function thrust()
	local ct = player.thrust
	
	if (btn(⬅️)) player.dx -= ct
	if (btn(➡️)) player.dx += ct
	if (btn(⬆️)) player.dy -= ct
	
	if (btn(⬆️) or btn(⬅️) 
			  or btn(➡️)) then
		sfx(0)
	end
end

function stay_on_screen()	
	local x_bound = mid(0, player.x, 119)
	local y_bound = mid(0, player.y, 119)
	
	if (player.x != x_bound) then
		player.x = x_bound	
		player.dx = 0
	end
	
	if (player.y != y_bound) then
		player.y = y_bound
		player.dy = 0
	end
end
-->8
function rndb(low, high)
	local difference = high - low + 1
	return flr(rnd(difference) + low)
end

function draw_stars()
	srand(stars_seed)
	for i=1,50 do
		pset(
						 rndb(0,127),
						 rndb(0,127),
						 rndb(5,7)
		)
	end
	srand(time())
end

function check_land()
	local l_x = flr(player.x)
	local r_x = flr(player.x + 7)
	local b_y = flr(player.y + 7)
	
	local over_pad = l_x > pad.x 
										and r_x < pad.x + pad.width

	local on_pad = b_y >= pad.y-1

	local is_slow = player.dy < 1
	
	if (over_pad and on_pad and is_slow) then
		end_game(true)
	elseif (over_pad and on_pad) then
		end_game(false)
	else
		for i=l_x,r_x do
			if (gnd[i] <= b_y) end_game(false)
		end
	end
end

function end_game(won)
	game_over = true
	win=won
	
	if (won) then
		sfx(1)
	else
		sfx(2)
	end
end
-->8
function make_ground()
	gnd = {}
	local top = 96
	local btm = 120
	
	pad = {}
	pad.width = 15
	pad.x = rndb(0, 126-pad.width)
	pad.y = rndb(top, btm)
	pad.sprite = 2
	
	-- create ground at pad
	for i=pad.x,pad.x+pad.width do
		gnd[i] = pad.y
	end	
	
	-- create ground right of pad
	for i=pad.x+pad.width+1,127 do
		local prev_h = gnd[i-1]
		local h = rndb(prev_h-3, prev_h+3)
		gnd[i] = mid(top, h, btm) 
	end

	-- create ground left of pad
	for i=pad.x-1,0,-1 do
		local prev_h = gnd[i+1]
		local h = rndb(prev_h-3, prev_h+3)
		gnd[i] = mid(top, h, btm)
	end
end

function draw_ground()
	for i=0,#gnd do
		line(i,127,i,gnd[i], 5)
	end
	
	spr(pad.sprite,pad.x,pad.y,2,1)
end
__gfx__
0000000000dddd007661ddddddddd7660000000000888800008a9800000000000000000000000000000000000000000000000000000000000000000000000000
000000000ddc7dd07666666666666666000000000899998000899800000000000000000000000000000000000000000000000000000000000000000000000000
00700700ddccc7dd007666666666660000000000899aa99800089000000000000000000000000000000000000000000000000000000000000000000000000000
00077000dacaacad0075656565656000000bd00089aaaa9800088000000007060000000000000000000000000000000000000000000000000000000000000000
00077000dd5555dd000000000000000000bbd00089aaaa9800008000000000670000000000000000000000000000000000000000000000000000000000000000
007007000dddddd000000000000000000bbbd000899aa99800000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000505505000000000000000000000d0000899998000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000dd0dd0dd00000000000000000000d0000088880000000000000000000000000000000000000000000000000000000000000000000000000000000000
__sfx__
00060000096501b6001b6001c6001c6001e6000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000c00001b0701b020170701702012070120201d0701d020000001607019070190200000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0004000037670316602c65025650206401a64014630106200c6200961006610046100261002610016100161000000000000000000000000000000000000000000000000000000000000000000000000000000000
