pub const DEBUG = true;

pub const SCREEN_WIDTH_PX = 240;
pub const SCREEN_HEIGHT_PX = 136;

pub const GRIDS_PER_LEVEL_X = 30;
pub const GRIDS_PER_LEVEL_Y = 17;
pub const PX_PER_GRID = 8;

/// Grid coordinates of the player's starting position for each level. These are
/// ABSOLUTE coordinates, not relative to the level's origin.
pub const PLAYER_START_POSITIONS = [_]u8{
    // Level 1
    17, 4,

    // Level 2
    17, 4,
};
