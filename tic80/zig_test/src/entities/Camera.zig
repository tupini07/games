const tic = @import("../tic80.zig");

const Vector2 = @import("./Vector2.zig").Vector2;
const Constants = @import("../constants.zig");

pub const Camera = struct {
    currentLevel: u32,

    pub fn New() Camera {
        return Camera{
            .currentLevel = 0,
        };
    }

    pub fn drawLevel(self: *Camera) void {
        var level_grid_orig = self.getLevelOriginGrid();

        tic.map(.{ .x = level_grid_orig.x, .y = level_grid_orig.y });
    }

    pub fn getLevelOriginGrid(self: *Camera) Vector2 {
        var level_origin_x = (self.currentLevel % 8) * Constants.GRIDS_PER_LEVEL_X;
        var level_origin_y = (self.currentLevel / 8) * Constants.GRIDS_PER_LEVEL_Y;

        return Vector2{
            .x = @intCast(level_origin_x),
            .y = @intCast(level_origin_y),
        };
    }

    pub fn getLevelOriginPixel(self: *Camera) Vector2 {
        var grid_origin = self.getLevelOriginGrid();
        return Vector2{
            .x = grid_origin.x * Constants.PX_PER_GRID,
            .y = grid_origin.y * Constants.PX_PER_GRID,
        };
    }

    pub fn mapLevelToWorldPixel(self: *Camera, levelCoordinates: Vector2) Vector2 {
        var level_origin = self.getLevelOriginPixel();

        return Vector2{
            .x = level_origin.x + levelCoordinates.x,
            .y = level_origin.y + levelCoordinates.y,
        };
    }

    pub fn mapLevelToWorldGrid(self: *Camera, levelCoordinates: Vector2) Vector2 {
        var level_origin = self.getLevelOriginGrid();

        return Vector2{
            .x = level_origin.x + levelCoordinates.x,
            .y = level_origin.y + levelCoordinates.y,
        };
    }
};
