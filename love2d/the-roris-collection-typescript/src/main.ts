import { KeyConstant, Scancode } from "love.keyboard";
import { globals } from "./globals";
import * as Input from "./lib/input";
import { BallSmash } from "./scenes/ball_smash";
import { DuckScene } from "./scenes/duck_scene";
import { IntroScene } from "./scenes/intro_scene";
import {
    Scene,
    drawActiveScene,
    registerScenes,
    switchScene,
    updateActiveScene,
} from "./scenes/scene_manager";
import hot_reload = require("./lib/hot_reload");

if (os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") === "1") {
    require("" + "lldebugger").start();
}

// if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
//     require("lldebugger").start()
// end

// ugly hack to avoid the TS compiler resolving this to a single file
Slab = require("./vendor/" + "Slab");
SlabDebug = require("./vendor/" + "Slab.SlabDebug");

let isFocused = true;

if (love.system.getOS() === "Android" || love.system.getOS() === "iOS") {
    love.window.setFullscreen(true);
}

let initializeScenes = () => {
    registerScenes([
        [Scene.Intro, IntroScene],
        [Scene.BallSmash, BallSmash],
        [Scene.Duck, DuckScene],
    ]);

    switchScene(Scene.Intro);
};

love.load = (args) => {
    Slab.Initialize(args);

    const [major, minor, revision, codename] = love.getVersion();
    print(`Love2D ${major}.${minor}.${revision} (${codename})`);

    initializeScenes();
};

love.draw = () => {
    drawActiveScene();
    Slab.Draw();
};

love.update = (dt: number) => {
    if (!isFocused) {
        love.timer.sleep(0.3);
        return;
    }

    Slab.Update(dt);

    if (globals.isDebug) {
        if (Slab.BeginMainMenuBar()) {
            if (Slab.BeginMenu("File")) {
                if (Slab.MenuItem("Quit")) {
                    love.event.quit();
                }
                Slab.EndMenu();
            }

            SlabDebug.Menu();
            Slab.EndMainMenuBar();
        }

        SlabDebug.Begin();
    }

    updateActiveScene(dt);

    Input.updateInput();
};

love.mousefocus = (focus: boolean) => {
    isFocused = focus;
};

love.mousepressed = (
    x: number,
    y: number,
    button: number,
    istouch: boolean,
) => {
    Input.mousepressed(x, y, button, istouch);
};

love.mousereleased = (
    x: number,
    y: number,
    button: number,
    istouch: boolean,
) => {
    Input.mousereleased(x, y, button, istouch);
};

love.keypressed = (key: KeyConstant, scancode: Scancode, isrepeat: boolean) => {
    Input.keypressed(key);

    if (key === "escape") {
        love.event.quit();
    }

    if (key === "f5") {
        const currentSceneName = globals.currentScene.name as Scene;
        hot_reload.reload_all_packages(currentSceneName);

        initializeScenes();
        switchScene(currentSceneName);
    }

    if (key === "f6") {
        globals.isDebug = !globals.isDebug;
    }
};

love.keyreleased = (key: KeyConstant, scancode: Scancode) => {
    Input.keyreleased(key);
};
