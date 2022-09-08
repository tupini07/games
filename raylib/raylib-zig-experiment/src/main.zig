const rl = @import("raylib");
const scene_manager = @import("./scenes/scene_manager.zig");

const screenWidth = 800;
const screenHeight = 800;

pub fn main() !void {
    rl.InitWindow(screenWidth, screenHeight, "[[[]]]]raylib-zig [core] example - basic window");
    var frameBuffer: rl.RenderTexture2D = rl.LoadRenderTexture(400, 400);

    rl.SetTargetFPS(60);

    scene_manager.InitSceneManager();

    while (!rl.WindowShouldClose()) {
        const dt = rl.GetFrameTime();

        if (rl.IsKeyDown(rl.KeyboardKey.KEY_Q)) {
            break;
        }

        // draw to frame buffer
        frameBuffer.Begin();

        rl.ClearBackground(rl.WHITE);
        updateAndDraw(dt);
        
        frameBuffer.End();

        // draw frame buffer to screen
        rl.BeginDrawing();
        rl.DrawTexturePro(
            frameBuffer.texture,
            rl.Rectangle {
                .x = 0,
                .y = 0,
                .width = @intToFloat(f32, frameBuffer.texture.width),
                .height =  @intToFloat(f32, -frameBuffer.texture.height)
            },
            rl.Rectangle {
                .x = 0,
                .y = 0,
                .width = screenWidth,
                .height = screenHeight
            },
            rl.Vector2 { .x = 0, .y = 0 },
            0, rl.WHITE
        );
        rl.EndDrawing();
    }

    rl.CloseWindow();
}


fn updateAndDraw(dt: f32) void {
    scene_manager.DoUpdate(dt);
    scene_manager.DoDraw();
}