PARTICLES = {}

local function make_circle_particle(x, y, dx, dy, dyy, size, c, lifetime)
    local p = {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        dyy = dyy,
        c = c,
        size = size,
        lifetime = lifetime
    }

    function p:update()
        if self.lifetime == 0 then del(PARTICLES, self) end
        self.lifetime = self.lifetime - 1

        self.x = self.x + self.dx
        self.y = self.y + self.dy
        self.dy = self.dy + self.dyy
    end

    function p:draw() circfill(self.x, self.y, self.size, self.c) end

    add(PARTICLES, p)
end

local function make_pixel_particle(x, y, dx, dy, dyy, c, lifetime)
    local p = {
        x = x,
        y = y,
        dx = dx,
        dy = dy,
        dyy = dyy,
        c = c,
        size = size,
        lifetime = lifetime
    }

    function p:update()
        if self.lifetime == 0 then del(PARTICLES, self) end
        self.lifetime = self.lifetime - 1

        self.x = self.x + self.dx
        self.y = self.y + self.dy
        self.dy = self.dy + self.dyy
    end

    function p:draw() pset(self.x, self.y, self.c) end

    add(PARTICLES, p)
end

return {
    make_pixel_particle = make_pixel_particle,
    make_particle = make_circle_particle,
    init = function() PARTICLES = {} end,
    update = function() for p in all(PARTICLES) do p:update() end end,
    draw = function() for p in all(PARTICLES) do p:draw() end end
}
