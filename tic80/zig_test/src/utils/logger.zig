const constants = @import("../constants.zig");
const tic = @import("../tic80.zig");

pub fn debug(comptime fmt: []const u8, fmtargs: anytype) void {
    if (constants.DEBUG) tic.tracef("[DEBUG] " ++ fmt, fmtargs);
}

pub fn info(comptime fmt: []const u8, fmtargs: anytype) void {
    tic.tracef("[INFO] " ++ fmt, fmtargs);
}
