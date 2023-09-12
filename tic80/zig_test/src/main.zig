const tic = @import("tic80.zig");
const map_utils = @import("./utils//map.zig");
const random = @import("./utils/random.zig");
const constants = @import("./constants.zig");

const scene_manager = @import("./scenes/scene_manager.zig");

export fn BOOT() void {
    random.initRandom();

    // This is actually pretty slow and the results are pretty bad, so...
    // better to jus set the patterns manually
    // map_utils.setRandomSandTileInMap();

    scene_manager.InitSceneManager();
}

export fn TIC() void {
    if (constants.DEBUG) {
        @setRuntimeSafety(true);
    }

    scene_manager.DoUpdate();
    scene_manager.DoDraw();
}

export fn BDR() void {}

export fn OVR() void {}
