const std = @import("std");

var rnd: std.rand.Random = undefined;

pub fn initRandom() void {
    var xoshiro = std.rand.DefaultPrng.init(0);
    rnd = xoshiro.random();
}

pub fn getInRange(comptime T: type, min: T, max: T) T {
    return rnd.intRangeLessThan(T, min, max);
}
