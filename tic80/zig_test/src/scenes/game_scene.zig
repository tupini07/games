const std = @import("std");
const tic = @import("../tic80.zig");
const controller = @import("../utils/controller.zig");
const constants = @import("../constants.zig");

const Camera = @import("../entities/camera.zig").Camera;
const KnownScenes = @import("known_scenes.zig").KnownScenes;
const Player = @import("../entities/Player.zig").Player;
const Vector2 = @import("../entities/Vector2.zig").Vector2;

pub const GameScene = struct {
    current_level: u8,
    camera: Camera,
    player: Player,

    pub fn Init() GameScene {
        var game = GameScene{
            .current_level = 0,
            .camera = Camera.New(),
            .player = Player.New(),
        };

        game.camera.currentLevel = 0;

        var first_pos_idx: usize = game.camera.currentLevel * 2;

        var starting_player_pos = Vector2{
            .x = constants.PLAYER_START_POSITIONS[first_pos_idx],
            .y = constants.PLAYER_START_POSITIONS[first_pos_idx + 1],
        };

        var world_pixel = starting_player_pos.mul_scalar(constants.PX_PER_GRID);

        game.player.head_pos.x = world_pixel.x;
        game.player.head_pos.y = world_pixel.y;

        return game;
    }

    pub fn Deinit(self: *GameScene) void {
        _ = self;
    }

    pub fn Draw(self: *GameScene) void {
        tic.cls(0);
        self.camera.drawLevel();
        _ = tic.print("hello, we're at in game", 10, 10, .{});

        self.player.Draw();
    }

    pub fn Update(self: *GameScene) ?KnownScenes {
        if (tic.pressed(controller.A)) {
            return KnownScenes.Intro;
        }

        // if (tic.pressed(controller.RIGHT)) {
        //     self.camera.currentLevel += 1;
        // }

        // if (tic.pressed(controller.LEFT)) {
        //     self.camera.currentLevel -= 1;
        // }

        if (!self.player.is_moving) {
            if (tic.pressed(controller.UP)) {
                self.player.StartMoving(.Up);
            } else if (tic.pressed(controller.DOWN)) {
                self.player.StartMoving(.Down);
            } else if (tic.pressed(controller.LEFT)) {
                self.player.StartMoving(.Left);
            } else if (tic.pressed(controller.RIGHT)) {
                self.player.StartMoving(.Right);
            }
        }

        self.player.Update();

        return null;
    }
};
