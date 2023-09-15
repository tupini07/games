const tic = @import("../tic80.zig");

const random = @import("../utils/random.zig");
const log = @import("../utils/logger.zig");

const ShapType = enum(u8) {
    Circle = 0,
    Square,
};

pub const Shape = struct {
    is_dead: bool = true,
    x: f32 = 0,
    y: f32 = 0,

    shape_type: ShapType = .Circle,
    size: i32 = 10,
    color: i32 = 10,

    pub fn brand_new(self: *Shape) void {
        self.is_dead = true;
    }

    pub fn init(self: *Shape) void {
        self.is_dead = false;

        self.x = random.getFloatInRange(f32, 5, 220);
        self.y = random.getFloatInRange(f32, 5, 126);
        self.size = random.getIntInRangeNorm(i32, 20, 100);
        self.color = random.getIntInRange(i32, 1, 15);

        self.shape_type = @enumFromInt(random.getIntInRange(u8, 0, 2));

        log.debug("Spawning shape: {}", .{self});
    }

    pub fn doUpdate(self: *Shape) void {
        self.size -= 1;
        if (self.size <= 0) {
            self.is_dead = true;
            return;
        }

        // if we're a square then center it so it seems to be shrinking towards the center
        if (self.shape_type == .Square) {
            self.x += 0.5;
            self.y += 0.5;
        }
    }

    pub fn doDraw(self: *Shape) void {
        const x_i: i32 = @intFromFloat(self.x);
        const y_i: i32 = @intFromFloat(self.y);
        switch (self.shape_type) {
            .Circle => {
                tic.circ(x_i, y_i, self.size, self.color);
                tic.circb(x_i, y_i, self.size, self.color - 1);
            },
            .Square => {
                tic.rect(x_i, y_i, self.size, self.size, self.color);
                tic.rectb(x_i, y_i, self.size, self.size, self.color - 1);
            },
        }
    }
};
