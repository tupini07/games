const std = @import("std");

pub fn round_to_multiple(num: i32, multiple_of: f32) i32 {
    return @as(i32, @intFromFloat(@round(@as(f32, @floatFromInt(num)) / multiple_of))) * @as(i32, @intFromFloat(multiple_of));
}
