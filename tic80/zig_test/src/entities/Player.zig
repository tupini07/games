const std = @import("std");
const tic = @import("../tic80.zig");
const map_utils = @import("../utils/map.zig");
const math_utils = @import("../utils/math.zig");
const logger = @import("../utils//logger.zig");

const Vector2 = @import("../entities/Vector2.zig").Vector2;

const PlayerSegment = struct {
    pos: Vector2,
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
        self.segments[self.num_segments].pos = pos;
        self.segments[self.num_segments].sprite = sprite;
        self.num_segments += 1;
    }

    pub fn StartMoving(self: *Player, direction: MoveDirection) void {
        if (self.is_moving) {
            unreachable;
        }
        logger.debug("Starting to move in direction: {}", .{direction});

        // find position to which the head should move to (e.g. the position until
        // which the head will hit a wall)
        var target_position = self.head_pos;
        while (true) {
            if (map_utils.tileHasFlagPx(target_position, .SOLID)) {
                logger.info("Found end position for move because there's a SOLID tile at {}", .{target_position});
                break;
            }

            if (self.SegmentInCell(target_position.x, target_position.y)) {
                logger.info("Found end position for move because there's a tongue segment at {}", .{target_position});
                break;
            }

            switch (self.current_move_direction) {
                MoveDirection.Up => target_position.y -= 1,
                MoveDirection.Left => target_position.x -= 1,
                MoveDirection.Down => target_position.y += 1,
                MoveDirection.Right => target_position.x += 1,
                MoveDirection.None => unreachable,
            }
        }

        // adjust for sprite size
        if (self.current_move_direction == .Right) target_position.x -= 16;
        if (self.current_move_direction == .Down) target_position.y -= 16;

        // round target to nearest multiple of 8
        const target_x = math_utils.round_to_multiple(target_position.x, 8.0);
        const target_y = math_utils.round_to_multiple(target_position.y, 8.0);

        if (std.meta.eql(self.head_pos, Vector2{ .x = target_x, .y = target_y })) {
            logger.info("Already at target position, not moving", .{});
            return;
        }

        self.is_moving = true;
        self.current_move_direction = direction;

        self.move_to_target = Vector2{ .x = target_x, .y = target_y };

        logger.debug("Set final target position at {} . Current head position is {}", .{ self.move_to_target, self.head_pos });
    }

    fn SegmentInCell(self: *Player, cell_x: i32, cell_y: i32) bool {
        const cell_to_check_x = math_utils.round_to_multiple(cell_x, 8.0);
        const cell_to_check_y = math_utils.round_to_multiple(cell_y, 8.0);

        const current_player_cell_x = math_utils.round_to_multiple(self.head_pos.x, 8.0);
        const current_player_cell_y = math_utils.round_to_multiple(self.head_pos.y, 8.0);

        if (cell_to_check_x == current_player_cell_x and cell_to_check_y == current_player_cell_y) {
            return false;
        }

        for (0..self.num_segments) |seg_idx| {
            const segment = self.segments[seg_idx];
            if (segment.pos.x == cell_to_check_x and segment.pos.y == cell_to_check_y) {
                return true;
            }
        }

        return false;
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

                // Is there already a segment in the current cell?
                const current_cell_x = math_utils.round_to_multiple(self.head_pos.x, 8.0);
                const current_cell_y = math_utils.round_to_multiple(self.head_pos.y, 8.0);

                if (!self.SegmentInCell(current_cell_x, current_cell_y)) {
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

                    self.AddSegment(Vector2{ .x = current_cell_x, .y = current_cell_y }, segment_sprite);
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
            segment.pos.x, segment.pos.y,
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
