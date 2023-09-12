const std = @import("std");

const tic = @import("../tic80.zig");

const Vector2 = @import("./Vector2.zig").Vector2;
const Constants = @import("../constants.zig");

pub var currentLevel: usize = 0;

pub fn drawLevel() void {
    var level_grid_orig = getLevelOriginGrid();

    tic.map(.{ .x = level_grid_orig.x, .y = level_grid_orig.y });
}

pub fn getLevelOriginGrid() Vector2 {
    var level_origin_x = (currentLevel % 8) * Constants.GRIDS_PER_LEVEL_X;
    var level_origin_y = (currentLevel / 8) * Constants.GRIDS_PER_LEVEL_Y;

    return Vector2{
        .x = @intCast(level_origin_x),
        .y = @intCast(level_origin_y),
    };
}

pub fn getLevelOriginPixel() Vector2 {
    var grid_origin = getLevelOriginGrid();
    return Vector2{
        .x = grid_origin.x * Constants.PX_PER_GRID,
        .y = grid_origin.y * Constants.PX_PER_GRID,
    };
}

pub fn mapLevelToWorldPixel(levelCoordinates: Vector2, comptime is_grid: bool) Vector2 {
    // assume `levelCoordinates` are in pixel position
    var coords = levelCoordinates;
    if (is_grid) {
        coords.x = coords.x * 8;
        coords.y = coords.y * 8;
    }

    var level_origin = getLevelOriginPixel();

    return Vector2{
        .x = level_origin.x + coords.x,
        .y = level_origin.y + coords.y,
    };
}

pub fn mapLevelToWorldGrid(levelCoordinates: Vector2, comptime is_pixel: bool) Vector2 {
    // assume `levelCoordinates` are in grid position
    var coords = levelCoordinates;
    if (is_pixel) {
        coords.x = @divTrunc(coords.x, 8);
        coords.y = @divTrunc(coords.y, 8);
    }

    var level_origin = getLevelOriginGrid();

    return Vector2{
        .x = level_origin.x + coords.x,
        .y = level_origin.y + coords.y,
    };
}

///////////////////////////////////////////////////////////////////////////////////////
// Tests
///////////////////////////////////////////////////////////////////////////////////////

test getLevelOriginGrid {
    currentLevel = 0;
    try std.testing.expectEqual(getLevelOriginGrid(), Vector2{ .x = 0, .y = 0 });

    currentLevel = 1;
    try std.testing.expectEqual(getLevelOriginGrid(), Vector2{ .x = 30, .y = 0 });

    currentLevel = 8;
    try std.testing.expectEqual(getLevelOriginGrid(), Vector2{ .x = 0, .y = 17 });
}

test getLevelOriginPixel {
    currentLevel = 0;
    try std.testing.expectEqual(getLevelOriginPixel(), Vector2{ .x = 0, .y = 0 });

    currentLevel = 1;
    try std.testing.expectEqual(getLevelOriginPixel(), Vector2{ .x = 30 * 8, .y = 0 });

    currentLevel = 8;
    try std.testing.expectEqual(getLevelOriginPixel(), Vector2{ .x = 0, .y = 17 * 8 });
}

test mapLevelToWorldPixel {
    currentLevel = 0;
    try std.testing.expectEqual(mapLevelToWorldPixel(Vector2{ .x = 0, .y = 0 }, false), Vector2{ .x = 0, .y = 0 });
    try std.testing.expectEqual(mapLevelToWorldPixel(Vector2{ .x = 1, .y = 0 }, false), Vector2{ .x = 1, .y = 0 });
    try std.testing.expectEqual(mapLevelToWorldPixel(Vector2{ .x = 0, .y = 1 }, false), Vector2{ .x = 0, .y = 1 });

    try std.testing.expectEqual(mapLevelToWorldPixel(Vector2{ .x = 0, .y = 0 }, true), Vector2{ .x = 0, .y = 0 });
    try std.testing.expectEqual(mapLevelToWorldPixel(Vector2{ .x = 1, .y = 0 }, true), Vector2{ .x = 8, .y = 0 });
    try std.testing.expectEqual(mapLevelToWorldPixel(Vector2{ .x = 0, .y = 1 }, true), Vector2{ .x = 0, .y = 8 });

    currentLevel = 1;
    try std.testing.expectEqual(mapLevelToWorldPixel(Vector2{ .x = 0, .y = 0 }, false), Vector2{ .x = 30 * 8, .y = 0 });
    try std.testing.expectEqual(mapLevelToWorldPixel(Vector2{ .x = 1, .y = 0 }, false), Vector2{ .x = (30 * 8) + 1, .y = 0 });
    try std.testing.expectEqual(mapLevelToWorldPixel(Vector2{ .x = 0, .y = 1 }, false), Vector2{ .x = 30 * 8, .y = 1 });

    currentLevel = 8;
    try std.testing.expectEqual(mapLevelToWorldPixel(Vector2{ .x = 0, .y = 0 }, false), Vector2{ .x = 0, .y = 17 * 8 });
    try std.testing.expectEqual(mapLevelToWorldPixel(Vector2{ .x = 1, .y = 0 }, false), Vector2{ .x = 1, .y = 17 * 8 });
    try std.testing.expectEqual(mapLevelToWorldPixel(Vector2{ .x = 0, .y = 1 }, false), Vector2{ .x = 0, .y = (17 * 8) + 1 });
}

test mapLevelToWorldGrid {
    currentLevel = 0;
    try std.testing.expectEqual(mapLevelToWorldGrid(Vector2{ .x = 0, .y = 0 }, false), Vector2{ .x = 0, .y = 0 });
    try std.testing.expectEqual(mapLevelToWorldGrid(Vector2{ .x = 1, .y = 0 }, false), Vector2{ .x = 1, .y = 0 });
    try std.testing.expectEqual(mapLevelToWorldGrid(Vector2{ .x = 0, .y = 1 }, false), Vector2{ .x = 0, .y = 1 });

    try std.testing.expectEqual(mapLevelToWorldGrid(Vector2{ .x = 0, .y = 0 }, true), Vector2{ .x = 0, .y = 0 });
    try std.testing.expectEqual(mapLevelToWorldGrid(Vector2{ .x = 1, .y = 0 }, true), Vector2{ .x = 0, .y = 0 });
    try std.testing.expectEqual(mapLevelToWorldGrid(Vector2{ .x = 0, .y = 1 }, true), Vector2{ .x = 0, .y = 0 });
    try std.testing.expectEqual(mapLevelToWorldGrid(Vector2{ .x = 8, .y = 8 }, true), Vector2{ .x = 1, .y = 1 });

    currentLevel = 1;
    try std.testing.expectEqual(mapLevelToWorldGrid(Vector2{ .x = 0, .y = 0 }, false), Vector2{ .x = 30, .y = 0 });
    try std.testing.expectEqual(mapLevelToWorldGrid(Vector2{ .x = 1, .y = 0 }, false), Vector2{ .x = 31, .y = 0 });
    try std.testing.expectEqual(mapLevelToWorldGrid(Vector2{ .x = 0, .y = 1 }, false), Vector2{ .x = 30, .y = 1 });

    currentLevel = 8;
    try std.testing.expectEqual(mapLevelToWorldGrid(Vector2{ .x = 0, .y = 0 }, false), Vector2{ .x = 0, .y = 17 });
    try std.testing.expectEqual(mapLevelToWorldGrid(Vector2{ .x = 1, .y = 0 }, false), Vector2{ .x = 1, .y = 17 });
    try std.testing.expectEqual(mapLevelToWorldGrid(Vector2{ .x = 0, .y = 1 }, false), Vector2{ .x = 0, .y = 18 });
}
