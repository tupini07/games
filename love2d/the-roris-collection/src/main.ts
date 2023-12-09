import { KeyConstant, Scancode } from "love.keyboard";
import { globals } from "./globals";
import hot_reload = require("./lib/hot_reload");

// ugly hack to avoid the compiler resolving this to a single file
Slab = require("./vendor/" + "Slab");
SlabDebug = require("./vendor/" + "Slab.SlabDebug");

let isFocused = true;

love.load = (args) => {
    Slab.Initialize(args)

    const [major, minor, revision, codename] = love.getVersion();
    print(`Love2D ${major}.${minor}.${revision} (${codename})`);

    globals.currentScene.init();
};

love.draw = () => {
    globals.currentScene.draw();
    Slab.Draw()
};

love.update = (dt: number) => {
    if (!isFocused) {
        love.timer.sleep(0.3);
        return;
    }

    Slab.Update(dt)

    globals.currentScene.update(dt);

    if (globals.isDebug) {
        if (Slab.BeginMainMenuBar()) {
            if (Slab.BeginMenu("File")) {
                if (Slab.MenuItem("Quit")) {
                    love.event.quit()
                }
                Slab.EndMenu()
            }

            SlabDebug.Menu()
            Slab.EndMainMenuBar()
        }

        SlabDebug.Begin()
    }
}

love.mousefocus = (focus: boolean) => {
    isFocused = focus;
}

love.keypressed = (key: KeyConstant, scancode: Scancode, isrepeat: boolean) => {
    if (key === "escape") {
        love.event.quit();
    }

    if (key === "f5") {
        hot_reload.reload_all_packages(globals.currentScene.name)
        const currentSceneClass = globals.currentScene.constructor as any;
        globals.currentScene = new currentSceneClass();
    }

    if (key === "f6") {
        globals.isDebug = !globals.isDebug;
    }
}