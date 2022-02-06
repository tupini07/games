pico-8 cartridge // http://www.pico-8.com
version 32
__lua__
-- this tab is only documentation

--[[
pico8 has four function to work
with coroutines:

-> cocreate(function name)
				creates coroutine from func
				but doesn't start it
-> coresume(coroutine)
				start or resume paused
				coroutine
-> costatus(coroutine)
				returns status of coroutine
				as: "running" "suspended" 
				"dead"
-> yield()
				gives control back to what
				called the coroutine
--]]


-->8
function _init()
	c_move=cocreate(move)
end

function _update()
	if c_move and 
				costatus(c_move) != "dead"
				then
		coresume(c_move)
	else
		c_move = nil
	end
	
	if (btnp() > 0) c_move = cocreate(move)
end

function _draw()
	cls(1)
	circ(x,y,r,12)
	print(current, 4, 4, 7)
end

function move()
	x,y,r = 32,32,8
	
	current="left to right"
	for i=32,96 do
		x=i
		yield()
	end
	
	current="top to bottom"
	for j=32,96 do
		y=j
		yield()
	end
	
	current="back to start"
	for i=96,32,-1 do
		x,y=i,i
		yield()
	end
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00077000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00700700000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
