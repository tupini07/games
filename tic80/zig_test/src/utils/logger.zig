const constants = @import("../constants.zig");
const tic = @import("../tic80.zig");

pub fn debug(comptime fmt: []const u8, fmtargs: anytype) void {
    if (constants.DEBUG) tic.tracef("[DEBUG] " ++ fmt, fmtargs);
}

pub fn info(comptime fmt: []const u8, fmtargs: anytype) void {
    tic.tracef("[INFO] " ++ fmt, fmtargs);
}

pub fn warn(comptime fmt: []const u8, fmtargs: anytype) void {
    tic.tracef("[WARN] " ++ fmt, fmtargs);
}

pub fn err(comptime fmt: []const u8, fmtargs: anytype) void {
    tic.tracef("[ERROR] " ++ fmt, fmtargs);
}
