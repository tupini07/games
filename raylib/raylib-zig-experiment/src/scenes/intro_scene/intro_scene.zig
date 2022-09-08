const std = @import("std");

const rl = @import("raylib");

const KnownScenes = @import("../known_scenes.zig").KnownScenes;

const boxWidth = 150;
const boxHeight = 20;

pub const IntroScene = struct {
    currentTime: f32,
    sceneAllocator: std.heap.ArenaAllocator,

    pub fn Init(topAllocator: std.mem.Allocator) IntroScene {
        return IntroScene {
            .currentTime = 0.0,
            .sceneAllocator = std.heap.ArenaAllocator.init(topAllocator),
        };
    }

    pub fn Draw(self: *IntroScene) void {
        rl.ClearBackground(rl.RAYWHITE);
        
        const cSin = std.math.sin(self.currentTime) * (boxWidth / 2);
        const cCos = std.math.cos(self.currentTime) * (boxHeight / 2);

        const posX = @intToFloat(f32, rl.GetMouseX()) / 2.0 - (boxWidth / 2);
        const posY = @intToFloat(f32, rl.GetMouseY()) / 2.0 - (boxHeight / 2);

        rl.DrawRectangle(
            @floatToInt(c_int, posX + cSin), 
            @floatToInt(c_int, posY + cCos), 
            boxWidth, 
            boxHeight, 
            rl.BLUE);


        const currentTimeStrC = rl.FormatText(
            "Current Time: %d", 
            @floatToInt(i32, self.currentTime));

        rl.DrawText(currentTimeStrC, 10, 10, 10, rl.RED);
    }

    pub fn Update(self: *IntroScene, dt: f32) ?KnownScenes {
        if (rl.IsKeyPressed(rl.KeyboardKey.KEY_D)) {
            std.debug.print("dt = {d} .. current time: {d}\n", .{dt, self.currentTime});
        }

        self.currentTime += dt;

        return null;
    }
};
