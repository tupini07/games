const std = @import("std");
const tic = @import("../tic80.zig");

const IntroScene = @import("./intro_scene.zig").IntroScene;
const GameScene = @import("./game_scene.zig").GameScene;
const KnownScenes = @import("./known_scenes.zig").KnownScenes;

var intro_scene: IntroScene = undefined;
var game_scene: GameScene = undefined;

var current_scene: KnownScenes = .Intro;

pub fn InitSceneManager() void {
    intro_scene = IntroScene.Init();
}

pub fn DoDraw() void {
    tic.rect(0, 0, 10, 10, 2);

    switch (current_scene) {
        .Intro => {
            intro_scene.Draw();
        },
        .Game => {
            game_scene.Draw();
        },
    }
}

pub fn DoUpdate() void {
    const newSceneOpt = switch (current_scene) {
        .Intro => intro_scene.Update(),
        .Game => game_scene.Update(),
    };

    if (newSceneOpt) |newScene| {
        tic.tracef("Switching to scene: {s}", .{@tagName(newScene)});

        // var buffer: [100]u8 = undefined;
        // var fba = std.heap.FixedBufferAllocator.init(&buffer);
        // var calloc = fba.allocator();
        // var aa = std.ArrayList(u32).init(calloc);
        // aa.append(33) catch unreachable;
        // aa.append(34) catch unreachable;
        // for (aa.items) |item| {
        //     tic.tracef("item: {d}", .{item});
        // }

        if (newScene != current_scene) {
            // first deinit the current scene
            switch (current_scene) {
                .Intro => intro_scene.Deinit(),
                .Game => game_scene.Deinit(),
            }

            // then init the new scene
            switch (newScene) {
                .Intro => intro_scene = IntroScene.Init(),
                .Game => game_scene = GameScene.Init(),
            }

            current_scene = newScene;
        }
    }
}
