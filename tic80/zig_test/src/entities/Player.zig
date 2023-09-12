const std = @import("std");
const tic = @import("../tic80.zig");
const map_utils = @import("../utils/map.zig");
const math_utils = @import("../utils/math.zig");
const Camera = @import("../entities/Camera.zig");
const logger = @import("../utils//logger.zig");

const Vector2 = @import("../entities/Vector2.zig").Vector2;

const PlayerSegment = struct {
    grid_pos: Vector2,
    pixel_pos: Vector2,
    sprite: u16,
};

const MoveDirection = enum(u8) {
    Up,
    Down,
    Left,
    Right,
    None,
};

pub const Player = struct {
    move_speed: u8 = 2,
    segments: [1000]PlayerSegment = undefined,
    num_segments: usize = 0,
    head_pos: Vector2 = Vector2{ .x = 0, .y = 0 },

    is_moving: bool = false,
    previous_move_direction: MoveDirection = MoveDirection.None,
    current_move_direction: MoveDirection = MoveDirection.None,
    move_to_target: Vector2 = Vector2{ .x = 0, .y = 0 },

    pub fn New() Player {
        var xx = Player{
            .head_pos = Vector2{ .x = 0, .y = 0 },
        };

        // xx.AddSegment(Vector2{ .x = 14, .y = 4 }, 96);

        return xx;
    }

    fn AddSegment(self: *Player, pos: Vector2, sprite: u16) void {
        const current_cell_x = math_utils.round_to_multiple(pos.x, 8);
        const current_cell_y = math_utils.round_to_multiple(pos.y, 8);

        const current_cell = Vector2{ .x = current_cell_x, .y = current_cell_y };

        logger.debug("Adding segment to: {}", .{current_cell});
        self.segments[self.num_segments].pixel_pos = current_cell;
        self.segments[self.num_segments].grid_pos = Camera.mapLevelToWorldGrid(current_cell, true);
        self.segments[self.num_segments].sprite = sprite;
        self.num_segments += 1;
    }

    fn IsThereSegmentAtGridPos(self: *Player, grid_pos: Vector2) bool {
        for (0..self.num_segments) |seg_idx| {
            const segment = self.segments[seg_idx];

            if (std.meta.eql(segment.grid_pos, grid_pos)) {
                return true;
            }
        }

        return false;
    }

    pub fn StartMoving(self: *Player, direction: MoveDirection) void {
        if (self.is_moving) {
            logger.err("We're starting to move when we shouldn't! This should not happen.", .{});
            unreachable;
        }

        logger.debug("Starting to move in direction: {}", .{direction});

        // find position to which the head should move to (e.g. the position until
        // which the head will hit a wall)
        var target_position_grid = Camera.mapLevelToWorldGrid(self.head_pos, true);
        var is_first_loop = true;

        while (true) {
            switch (direction) {
                MoveDirection.Up => target_position_grid.y -= 2,
                MoveDirection.Left => target_position_grid.x -= 2,
                MoveDirection.Down => target_position_grid.y += 2,
                MoveDirection.Right => target_position_grid.x += 2,
                MoveDirection.None => unreachable,
            }

            logger.info("Looking for posision. Current target in grid coords is {}", .{target_position_grid});
            if (map_utils.tileHasFlagGrid(target_position_grid, .SOLID)) {
                logger.info("Found end position for move because there's a SOLID tile at {}", .{target_position_grid});
                break;
            }

            if (self.IsThereSegmentAtGridPos(target_position_grid)) {
                logger.info("Found end position for move because there's a segment at {}", .{target_position_grid});
                break;
            }

            is_first_loop = false;
        }

        // if we're still at the first loop then the move was invalid and we can exit
        // early
        if (is_first_loop) {
            logger.debug("Exiting early from Player.StartMoving because moving in the specified direction is invalid.", .{});
            return;
        }

        // undo last move
        switch (direction) {
            MoveDirection.Up => target_position_grid.y += 2,
            MoveDirection.Left => target_position_grid.x += 2,
            // down and right are by 2 because sprite is 2x2
            MoveDirection.Down => target_position_grid.y -= 2,
            MoveDirection.Right => target_position_grid.x -= 2,
            MoveDirection.None => unreachable,
        }

        const target_px = target_position_grid.mul_scalar(8);

        if (std.meta.eql(self.head_pos, target_px)) {
            logger.info("Already at target position, not moving", .{});
            return;
        } else {
            self.is_moving = true;

            self.previous_move_direction = self.current_move_direction;
            self.current_move_direction = direction;

            self.move_to_target = target_px;

            logger.debug("Set final target position at {} . Current head position is {}", .{ self.move_to_target, self.head_pos });

            // add a corner segment if we're turning
            if (self.previous_move_direction != self.current_move_direction) {
                var corner_segment_sprite: u16 = 288; // top left corner
                if (self.previous_move_direction == .Up and self.current_move_direction == .Right) {
                    corner_segment_sprite = 290; // top right corner
                }
                if (self.previous_move_direction == .Down and self.current_move_direction == .Left) {
                    corner_segment_sprite = 320; // bottom left corner
                }
                if (self.previous_move_direction == .Down and self.current_move_direction == .Right) {
                    corner_segment_sprite = 322; // bottom right corner
                }
                self.AddSegment(self.head_pos, corner_segment_sprite);
            }
        }
    }

    fn HasOvershotTarget(self: *Player) bool {
        if (self.current_move_direction == .Up) {
            return self.head_pos.y < self.move_to_target.y;
        }

        if (self.current_move_direction == .Down) {
            return self.head_pos.y > self.move_to_target.y;
        }

        if (self.current_move_direction == .Left) {
            return self.head_pos.x < self.move_to_target.x;
        }

        if (self.current_move_direction == .Right) {
            return self.head_pos.x > self.move_to_target.x;
        }

        return false;
    }

    pub fn Update(self: *Player) void {
        if (self.is_moving) {
            if (!self.HasOvershotTarget()) {
                switch (self.current_move_direction) {
                    MoveDirection.Up => self.head_pos.y -= self.move_speed,
                    MoveDirection.Down => self.head_pos.y += self.move_speed,
                    MoveDirection.Left => self.head_pos.x -= self.move_speed,
                    MoveDirection.Right => self.head_pos.x += self.move_speed,
                    MoveDirection.None => unreachable,
                }

                const current_grid_pos = Camera.mapLevelToWorldGrid(self.head_pos, true);
                const is_there_segment_in_current_cell = self.IsThereSegmentAtGridPos(current_grid_pos);

                if (!is_there_segment_in_current_cell) {
                    const segment_left_to_right = 256;
                    const segment_top_to_bottom = 258;
                    const segment_top_left_corner = 288;
                    _ = segment_top_left_corner;
                    const segment_top_right_corner = 290;
                    _ = segment_top_right_corner;
                    const segment_bottom_left_corner = 320;
                    _ = segment_bottom_left_corner;
                    const segment_bottom_right_corner = 322;
                    _ = segment_bottom_right_corner;

                    var segment_sprite: u16 = segment_left_to_right;
                    if (self.current_move_direction == .Up or self.current_move_direction == .Down) {
                        segment_sprite = segment_top_to_bottom;
                    }

                    self.AddSegment(self.head_pos, segment_sprite);
                }
            } else {
                // move to the nearest multiple of 8
                // self.head_pos.x = @divTrunc(self.head_pos.x, 8) * 8;
                self.head_pos = self.move_to_target;
                self.is_moving = false;
            }
        }
    }

    pub fn Draw(self: *Player) void {
        for (0..self.num_segments) |seg_idx| {
            const segment = self.segments[seg_idx];

            tic.spr(segment.sprite,
            // a comment to prevent auto-formatting from breaking the line
            segment.pixel_pos.x, segment.pixel_pos.y,
            // args!
            .{ .w = 2, .h = 2, .transparent = &.{0} });
        }

        // Draw head
        var head_sprite: i32 = 264; // No direction
        if (self.current_move_direction != .None) head_sprite = 260; // heading right

        if (self.current_move_direction == .Up or self.current_move_direction == .Down) {
            head_sprite = 262; // heading down
        }

        var flip_h = self.current_move_direction == .Left;

        var flip_v = self.current_move_direction == .Up;

        var flipit: tic.Flip = .no;
        if (flip_h and !flip_v) flipit = .horizontal;
        if (!flip_h and flip_v) flipit = .vertical;
        if (flip_h and flip_v) flipit = .both;

        tic.spr(head_sprite, self.head_pos.x, self.head_pos.y, .{
            .w = 2,
            .h = 2,
            .transparent = &.{0},
            //
            .flip = flipit,
        });
    }
};
