const std = @import("std");

const IntroScene = @import("./intro_scene/intro_scene.zig").IntroScene;
const KnownScenes = @import("./known_scenes.zig").KnownScenes;

var intro_scene: IntroScene = undefined;

var current_scene: KnownScenes = .Intro;
var gpa = std.heap.GeneralPurposeAllocator(.{}){};

pub fn InitSceneManager() void {
    current_scene = .Intro;
    intro_scene = IntroScene.Init(gpa.allocator());
}

pub fn DoDraw() void {
    _ = switch (current_scene) {
        .Intro => intro_scene.Draw(),
    };
}

pub fn DoUpdate(dt: f32) void {
    const newSceneOpt = switch (current_scene) {
        .Intro => intro_scene.Update(dt),
    };

    if (newSceneOpt) |newScene| {
        std.debug.print("new scene: {s}", .{newScene});
    }
}
