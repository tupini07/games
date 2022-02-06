-- main

--[[

todo list:
	- save and restore data
	- clean up lose and win messages
    - Add fishies for the cat to eat!
    - Add nicer graphics to blocks and cat
	- what happens when game finished
  - consider swapping map tiles color at certain levels
    - eg, 9 for lvls<5, 10 for lvls 5<x<10, etc
	
]]--

function _init()
	level_n=0

	fade(15)
	fade_level=15
	fade_target=0
	
	bump_duration=0
	bump_offset={x=0,y=0}
	
	init_level()

	debug_log={}
	_upd=update_game
end 


function _update60()
	_upd()
	update_particles()
end


function _draw()
	do_bump_camera()

	cls(9)

	map()

	pl_draw()
	draw_particles()
	draw_game_state()

	draw_fade()
	
	local ox,oy=get_level_origin_world()
	cursor(ox+4,oy+4)
	color(8)
	for txt in all(debug_log) do
		print(txt)
	end
	color()

end

function debug(txt)
	add(debug_log, txt)
end


function init_level()
	setup_camera()

	particles = {}
	
	pl_head={x=0,y=0}
	pl_butt={x=0,y=0}

	pl_segments={}
	is_moving = false
	
	game_finished=false
	game_won=false
	
	local start_x, start_y = get_level_origin()

	for x=start_x,start_x+15 do
		for y=start_y,start_y+15 do
			local tile = mget(x,y)
			
			-- if we see the tail
			if tile == 14 then
				pl_butt.x = x*8
				pl_butt.y = y*8
				
				add(pl_segments,{
						x=x*8,
						y=y*8,
						sprx=0,spry=48,
						dir={x=0,y=0}
				})

				-- if we see the head
			elseif tile == 15 then
				pl_head={x=x*8,y=y*8}
			end
		end
	end
	
	-- check in which direction head
	-- and tail should be pointing
	local dir = {
		x=pl_head.x-pl_butt.x,
		y=pl_head.y-pl_butt.y
	}
	if dir.x ~= 0 then 
		dir.x = sgn(dir.x)
	end
	
	if dir.y ~= 0 then
		dir.y = sgn(dir.y)
	end
	
	pl_head.dir = dir
	
	-- don't want butt to have
	-- reference to the same table
	-- as head
	pl_butt.dir = {x=dir.x,
				   y=dir.y}
end
-->8
-- drawing

function pl_draw()
	for s in all(pl_segments) do

		-- todo: add here draw for
		-- corner stuff
		-- remember that s.dir indicates
		-- the direction head was travelling
		-- in before turning. and
		-- s.next_dir holds the x and y
		-- of the next direction
		if not s.is_corner then
			draw_segment(s,
						 16,48,
						 16,32)
		else
			local sx,sy = 48,32

			local flipy = s.dir.y > 0 or s.next_dir.y < 0 
			local flipx = s.dir.x < 0 or s.next_dir.x > 0
			
			sspr(sx,sy,
				 16,16,
				 s.x, 
				 s.y,
				 16,16,
				 flipx,
				 flipy)	 	
		end
	end

	-- draw butt
	draw_segment(pl_butt,
				 0,48,
				 0,32)

	-- draw head
	draw_segment(pl_head,
				 32,48,
				 32,32)
end

function draw_particles()
	for p in all(particles) do
		p:draw()
	end
end

-- draws a segment (head, body,
-- or butt) provided the sprite
-- coords for when horizontal 
-- (xh,yh) and when vertical
-- (xv,yv).
function draw_segment(seg,xh,yh,xv,yv)
	local sx,sy = xh,yh
	local vertical,flipx,flipy=should_vertical_and_flip(seg.dir)

	if vertical then
		sx,sy = xv,yv
	end
	
	sspr(sx,sy,
		 16,16,
		 seg.x,
		 seg.y,
		 16,16,
		 flipx,flipy)
end

function should_vertical_and_flip(dir)
	--- default case it facing 
	--- to the right
	
	local vertical,flipx,flipy=false,false,false
	
	if dir.x < 0 then
		flipx = true
	end
	
	-- default vertical case is
	-- facing downwards
	if dir.y > 0 then
		vertical=true
	end
	
	if dir.y < 0 then
		vertical=true
		flipy=true
	end

	return vertical,flipx,flipy
end

function draw_game_state()
	if game_finished then
		if game_won then
			draw_game_won()
		else
			draw_game_lost()
		end
	end
end

function draw_game_won()
	local ox,oy=get_level_origin_world()
	cursor(ox+4,oy+4)
	print("game won ♥")
	print("press ❎ to continue")
end

function draw_game_lost()
	local ox,oy=get_level_origin_world()
	cursor(ox+4,oy+4)
	print("game lost :(")
	print("press ❎ to restart")
end

function draw_fade()
	if fade_level ~= fade_target then
		--		debug("fl:"..fade_level)
		local dif = fade_target - fade_level
		fade_level += sgn(dif)
		fade(fade_level)
	end
end
-->8
-- updates

function handle_input()
	if is_moving then
		return
	end	

	if btnp(1) then
		try_to_move(1,0)
	elseif btnp(0) then
		try_to_move(-1,0)
	elseif btnp(2) then
		try_to_move(0,-1)
	elseif btnp(3) then
		try_to_move(0,1)
	end
end

function update_particles()
	for p in all(particles) do
		p:update()
	end
end

function update_game()
	handle_input()
	check_player_move()
	check_if_should_add_segment()
end

function update_gameover()
	if btnp(5) then
		fade_target=15
	end
	
	if fade_level==15 then
		fade_target=0
		init_level()
		_upd=update_game		
	end
end

function update_game_won()
	if btnp(5) then
		fade_target=15
	end

	if fade_level==15 then
		fade_target=0
		level_n += 1
		init_level()
		_upd=update_game
	end
end
-->8
-- player stuff

--[[
	this function will check if player
	can move in direction dx,dy. if
	yes then a movement request will
	be made.
]]--
function try_to_move(dx,dy)
	local tx,ty = pl_head.x+dx,pl_head.y+dy

	-- we're moving to the right
	if dx == 1 then
		tx += 15
	end

	-- we're moving downwards
	if dy == 1 then
		ty += 15
	end

	if can_move_to(tx, ty) then
		pl_head.dir = {x=dx,y=dy}
		is_moving=true
		check_if_last_segment_is_corner()
	end
end

function check_player_move()
	-- if pl_head.dir is not (0,0)
	-- then move until we hit a 
	-- wall and then set to (0,0)

	-- should not be able to move
	-- back to a point that already
	-- has a body segment in it

	local move_speed = 2
	local was_moving = is_moving
	
	if is_moving then
		--		local tx = pl_head.x + pl_head.dir.x * move_speed
		--		local ty = pl_head.y + pl_head.dir.y * move_speed
		--
		--	 -- we're moving to the right
		--		if pl_head.dir.x == 1 then
		--			tx += 15
		--		end
		--
		--		-- we're moving downwards
		--		if pl_head.dir.y == 1 then
		--			ty += 15
		--		end
		--
		--		if can_move_to(tx, ty) then
		--			pl_head.x = tx
		--			pl_head.y = ty
		--		else
		--		 pl_head.x = flr(tx/16)*16
		--		 bump_camera(-pl_head.dir.x,-pl_head.dir.y)
		--		 is_moving=false
		--		end
		
		-- move right
		if pl_head.dir.x > 0 then
			local tx = pl_head.x + move_speed
			if can_move_to(tx+15, pl_head.y) then
				pl_head.x = tx
			else
				pl_head.x = flr(tx/16)*16
				bump_camera(-1,0)
				is_moving=false
				spawn_bump_particles(pl_head.x+16, pl_head.y+8)
			end
		end	
		
		-- move left
		if pl_head.dir.x < 0 then
			local tx = pl_head.x - move_speed
			if can_move_to(tx, pl_head.y) then
				pl_head.x = tx
			else
				pl_head.x = flr(pl_head.x/16)*16
				bump_camera(1,0)
				is_moving=false
				spawn_bump_particles(pl_head.x, pl_head.y+8)
			end
		end	
		
		-- move up
		if pl_head.dir.y < 0 then
			local ty = pl_head.y - move_speed
			if can_move_to(pl_head.x, ty) then
				pl_head.y = ty
			else
				pl_head.y = flr(pl_head.y/16)*16
				bump_camera(0,1)
				is_moving=false
				spawn_bump_particles(pl_head.x+8, pl_head.y)
			end
		end	
		
		-- move down
		if pl_head.dir.y > 0 then
			local ty = pl_head.y + move_speed
			if can_move_to(pl_head.x, ty+15) then
				pl_head.y = ty
			else
				pl_head.y = flr(ty/16)*16
				bump_camera(0,-1)
				is_moving=false
				spawn_bump_particles(pl_head.x+8, pl_head.y+16)
			end
		end	

	end
	
	-- if we stopped moving then check
	-- for game end
	if was_moving and not is_moving then
		check_game_end()
	end
end

function check_if_should_add_segment()
	-- add a segment body to map
	-- if necessary
	if pl_head.x%16 == 0 and 
		pl_head.y%16 == 0 then

		add(pl_segments, {
				x=pl_head.x,
				y=pl_head.y,
				dir={x=pl_head.dir.x,
					 y=pl_head.dir.y},
		})
		
	end
end

function check_if_last_segment_is_corner()
	local lss = pl_segments[#pl_segments]

	lss.is_corner = lss.dir.x ~= pl_head.dir.x and
		lss.dir.y ~= pl_head.dir.y

	if lss.is_corner then
		lss.next_dir = { x=pl_head.dir.x,
						 y=pl_head.dir.y}
	end
	
end
-->8
-- gameplay

function check_game_end()
	if not are_there_valid_moves() then
		game_finished=true
		if check_if_game_won() then
			game_won=true
			_upd=update_game_won
		else
			game_won=false
			_upd=update_gameover
		end
	end
end

function check_if_game_won()
	-- check all squares in grid
	-- for solid or segment. if
	-- there is an empty space
	-- then game was lost
	
	local start_x, start_y = get_level_origin()

	for x=start_x,start_x+15 do
		for y=start_y,start_y+15 do
			if not is_map_tile_solid(x,y) then
				if not is_segment_at_world_cords(x*8,y*8) then
					return false
				end
			end
		end
	end

	return true
end

function are_there_valid_moves()
	local px, py = pl_head.x, pl_head.y
	
	-- check top
	if can_move_to(px,py-16) then
		return true
	end
	
	-- check bottom
	if can_move_to(px,py+16) then
		return true
	end
	
	-- check left
	if can_move_to(px-16,py) then
		return true
	end	
	
	-- check right
	if can_move_to(px+16,py) then
		return true
	end
	
	return false
end

function can_move_to(worldx, worldy)
	-- cannot move if x,y is solid	
	if is_solid(worldx, worldy) then
		return false
	end
	
	-- nor if there is a body
	-- segment there	
	return not is_segment_at_world_cords(worldx, worldy)
end

function is_segment_at_world_cords(worldx, worldy)

	local gx,gy = grid_coords(worldx, worldy)
	
	-- grid position can be any 1/8
	-- square. we move only in increments
	-- of 16, so we need to 'floor'
	-- it to the neares 1/16
	local gx16,gy16 = flr(gx/2)*2, flr(gy/2)*2
	
	for s in all(pl_segments) do
		local sgx,sgy=grid_coords(s.x,s.y)
		if sgx == gx16 and 
			sgy == gy16 then
			return true
		end
	end
	
	return false
end
-->8
-- map utils

function is_solid(worldx, worldy)
	local gx,gy = grid_coords(worldx, worldy)
    return is_map_tile_solid(gx,gy)
end

function is_map_tile_solid(mapx, mapy)
	local tile = mget(mapx, mapy)
	return fget(tile, 0)		
end

function grid_coords(worldx,worldy)
	return flr(worldx/8), flr(worldy/8)
end


-->8
-- camera stuff

-- returns grid coordinates
-- for the origin point of the
-- level
function get_level_origin()
	-- 8 columns in a row in map
	local col = level_n%8
	
	-- there are 4 rows
	local row = flr(level_n/8)
	
	local origin_x = col*16
	local origin_y = row*16
	
	return origin_x, origin_y
end

function get_level_origin_world()
	local gx,gy = get_level_origin()
	return gx*8, gy*8
end

function setup_camera()
	local ox, oy = get_level_origin_world()

	camera(ox+bump_offset.x, 
		   oy+bump_offset.y)
end


function fade(i)
	local fadetable={
		{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0},
		{1,1,129,129,129,129,129,129,129,129,0,0,0,0,0},
		{2,2,2,130,130,130,130,130,128,128,128,128,128,0,0},
		{3,3,3,131,131,131,131,129,129,129,129,129,0,0,0},
		{4,4,132,132,132,132,132,132,130,128,128,128,128,0,0},
		{5,5,133,133,133,133,130,130,128,128,128,128,128,0,0},
		{6,6,134,13,13,13,141,5,5,5,133,130,128,128,0},
		{7,6,6,6,134,134,134,134,5,5,5,133,130,128,0},
		{8,8,136,136,136,136,132,132,132,130,128,128,128,128,0},
		{9,9,9,4,4,4,4,132,132,132,128,128,128,128,0},
		{10,10,138,138,138,4,4,4,132,132,133,128,128,128,0},
		{11,139,139,139,139,3,3,3,3,129,129,129,0,0,0},
		{12,12,12,140,140,140,140,131,131,131,1,129,129,129,0},
		{13,13,141,141,5,5,5,133,133,130,129,129,128,128,0},
		{14,14,14,134,134,141,141,2,2,133,130,130,128,128,0},
		{15,143,143,134,134,134,134,5,5,5,133,133,128,128,0}
	}
	for c=0,15 do
		if flr(i+1)>=16 then
			pal(c,0)
		else
			pal(c,fadetable[c+1][flr(i+1)])
		end
	end
end

function bump_camera(xo,yo)
	bump_offset={x=xo,y=yo}
	bump_duration=2
	bump_need_recoil=true
	setup_camera()
	sfx(0)
end

function do_bump_camera()
	if bump_duration > 0 then

		bump_duration -= 1
		if bump_duration == 0 then
			bump_offset={x=0,y=0}
			setup_camera()
		end

	end
end

-->8
-- particles

function spawn_bump_particles(x, y)
	local dir_non_0 = function()
		return {x=pl_head.dir.x ~= 0 and 1 or 0,
				y=pl_head.dir.y ~= 0 and 1 or 0}
	end

	for _=1,5 do
		local p = {
			-- we only want deviation from center if we're moving in the
			-- orthogonal position
			x=x+(rnd(8)-4)*dir_non_0().y,
			y=y+(rnd(8)-4)*dir_non_0().x,
			r=3,
			vx=0.5*pl_head.dir.x,
			vy=0.5*pl_head.dir.y,
			lifetime=7
		}

		function p:draw()
			circfill(self.x, self.y, self.r, 7)
		end

		function p:update()
			self.x += self.vx
			self.y += self.vy
			self.lifetime -= 1

			if self.lifetime % 2 == 0 and self.r > 1 then
				self.r -= 1
			end

			if self.lifetime <= 0 then
				del(particles, self)
			end
		end

		add(particles, p)
	end
end