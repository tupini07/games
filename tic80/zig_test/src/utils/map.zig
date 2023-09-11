const std = @import("std");

const tic = @import("../tic80.zig");
const constants = @import("../constants.zig");
const random = @import("./random.zig");

const Vector2 = @import("../entities/Vector2.zig").Vector2;

const TileFlag = enum(u8) {
    SOLID = 0,
    TONGUE,
    ANT,
};

/// This calls tic.mset to set all empty tiles to a random sand tile. Ideally
/// this should be called only once when the game starts.
pub fn setRandomSandTileInMap() void {
    tic.trace("Setting random sand tiles in the map");

    // there are 240 tiles on the X dim, and 136 on the Y dim
    for (0..240) |x_idx| {
        for (0..136) |y_idx| {
            var tt_x: i32 = @intCast(x_idx);
            var tt_y: i32 = @intCast(y_idx);

            tic.tracef("Processing x:{d} and y:{d}", .{ tt_x, tt_y });

            var tile_idx = tic.mget(tt_x, tt_y);
            if (tile_idx == 0) {
                // chose a random tile from the sand tiles that go from index 1 to 12
                tile_idx = random.getInRange(u8, 1, 13);
                tic.mset(tt_x, tt_y, @intCast(tile_idx));
            }
        }
    }
}

/// checks whether the tile has the specific flag using the grid coordinates
/// into the map
pub fn tileHasFlagGrid(pos: Vector2, flag: TileFlag) bool {
    var sprite_idx = tic.mget(pos.x, pos.y);
    return tic.fget(sprite_idx, @intFromEnum(flag));
}

/// checks whether the tile has the specific flag using the pixel coordinates
/// into the map
pub fn tileHasFlagPx(pos: Vector2, flag: TileFlag) bool {
    var grid_pos_x = @divTrunc(pos.x, constants.PX_PER_GRID);
    var grid_pos_y = @divTrunc(pos.y, constants.PX_PER_GRID);

    return tileHasFlagGrid(Vector2{ .x = grid_pos_x, .y = grid_pos_y }, flag);
}
