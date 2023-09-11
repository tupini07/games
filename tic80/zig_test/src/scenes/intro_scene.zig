const std = @import("std");
const tic = @import("../tic80.zig");
const controller = @import("../utils/controller.zig");

const KnownScenes = @import("known_scenes.zig").KnownScenes;

pub const IntroScene = struct {
    t: u8,

    pub fn Init() IntroScene {
        return IntroScene{
            .t = 0,
        };
    }

    pub fn Deinit(self: *IntroScene) void {
        self.t = 0;
    }

    pub fn Draw(self: *IntroScene) void {
        tic.cls(0);
        _ = tic.printf("hello, we're at {d}", .{self.t}, 10, 10, .{});
        _ = tic.print("press Z/A to continue", 10, 20, .{});
    }

    pub fn Update(self: *IntroScene) ?KnownScenes {
        self.t += 1;

        if (tic.pressed(controller.A)) {
            return KnownScenes.Game;
        }

        return null;
    }
};
