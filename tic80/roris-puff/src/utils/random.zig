const std = @import("std");

var rnd: std.rand.Random = undefined;

pub fn initRandom() void {
    var xoshiro = std.rand.DefaultPrng.init(0);
    rnd = xoshiro.random();
}

pub fn getFloatInRange(comptime T: type, min: T, max: T) T {
    const upper_limit: T = max - min;
    return min + @as(T, getFloat(T) * upper_limit);
}

pub fn getIntInRange(comptime T: type, min: T, max: T) T {
    const f_val = getFloatInRange(f32, @floatFromInt(min), @floatFromInt(max));
    return @intFromFloat(f_val);
}

pub fn getFloatInRangeNorm(comptime T: type, min: T, max: T) T {
    // return min + @as(T, (rnd.floatNorm(T) * stdev + mean) * upper_limit);
    const stdev = (max - min) / 6.0;
    const mean = (max + min) / 2.0;
    const f_val = rnd.floatNorm(f32) * stdev + mean;
    return @as(T, f_val);
}

pub fn getIntInRangeNorm(comptime T: type, min: T, max: T) T {
    const f_val = getFloatInRangeNorm(f32, @floatFromInt(min), @floatFromInt(max));
    return @intFromFloat(f_val);
}

pub fn getFloat(comptime T: type) T {
    return rnd.float(T);
}
