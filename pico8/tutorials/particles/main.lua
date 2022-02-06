function _init()
    particles = {}
    gravity = 0.1
    maximum_velocity = 2
    min_time = 2
    max_time = 5
    min_life = 90
    max_life = 120
    t = 0
    cols = {1, 1, 1, 13, 13, 12, 12, 7}
    burst = 50

    next_p = rndb(min_time, max_time)
    last_position = {rndb(62,66), rndb(62,66)}
    all_last_positions = {last_position}
end

function _update() 
    t = t + 1
    if (t == next_p) then
        last_position =  {rndb(62,66), rndb(62,66)}
        add(all_last_positions, last_position)

        add_p(
            last_position[1],    
            last_position[2])
        next_p=rndb(min_time, max_time)
        t = 0
    end
    
    -- burst
    if (btnp(4)) then
        for i=1,burst do
            add_p(64, 64)
        end
    end
    
    foreach(particles, update_p)
end


function _draw()
    cls()
    print("press z to get a burst!", 1,1,4)

    for lp in all(all_last_positions) do
        pset(lp[1], lp[2], 11)
    end

    pset(last_position[1], last_position[2], 10)
    foreach(particles, draw_p)
end

-- returns a random number between `high` and `low`
function rndb(low, high)
    return flr(rnd(high - low + 1) + low)
end


function add_p(x, y)
    local life_start = rndb(min_life, max_life)
    local p = {
        x = x, y = y,
        dx = rnd(maximum_velocity) - maximum_velocity/2,
        dy = rnd(maximum_velocity) * -1,
        life_start = life_start,
        life = life_start
    }

    add(particles, p)
end

function update_p(p)
    if (p.life <= 0) then
        del(particles, p)
    else
        p.dy += gravity

        -- if it'll go out of frame by next update then make it bounce
        if ((p.y + p.dy) > 127) p.dy *= -0.8

        p.x += p.dx
        p.y += p.dy

        p.life -= 1
    end
end

function draw_p(p)
    local pcol = flr(p.life/p.life_start * #cols + 1)
    pset(p.x, p.y, cols[pcol])
end