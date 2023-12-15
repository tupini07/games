import { IScene } from "./iscene";
import { Scene, switchScene } from "./scene_manager";

export class IntroScene implements IScene {
    name: string = "intro_scene";

    init(): void {}

    draw(): void {
        love.graphics.clear(0.83, 0.8, 0.8);
    }

    exit(): void {}

    update(dt: number): void {
        Slab.BeginWindow("MenuWindow", {
            Title: "Roris Mini Games",
            X: 0,
            Y: 0,
            W: love.graphics.getWidth(),
            H: love.graphics.getHeight(),
            ShowMinimize: false,
            AllowMove: false,
            AllowResize: false,
            AutoSizeWindow: false,
            ResetPosition: true,
            ResetSize: true,
        });
        Slab.Text("Select a minigame!");
        Slab.BeginListBox("MinigamesList", { StretchW: true, StretchH: true });

        const minigames: [string, Scene][] = [["Ball Smash", Scene.BallSmash]];

        for (const minigame of minigames) {
            Slab.BeginListBoxItem(minigame[0]);
            Slab.Text(minigame[0]);
            if (Slab.IsListBoxItemClicked(1)) {
                switchScene(minigame[1]);
            }
            Slab.EndListBoxItem();
        }

        Slab.EndListBox();
        Slab.EndWindow();
    }
}
