import { globals } from "../globals";
import { IScene } from "./iscene";


export enum Scene {
    Intro = "intro_scene",
    BallSmash = 'ball_smash',
}

const sceneConstructors: { [key in Scene]: new () => IScene } = {
    [Scene.Intro]: null as any,
    [Scene.BallSmash]: null as any,
}

export function registerScene(scene: Scene, constructor: new () => IScene) {
    sceneConstructors[scene] = constructor;
}

export function registerScenes(scenes: [Scene, new () => IScene][]) {
    for (const scene of scenes) {
        registerScene(scene[0], scene[1]);
    }
}

export function switchScene(scene: Scene) {
    const SceneConstructor = sceneConstructors[scene];
    globals.currentScene = new SceneConstructor();
    globals.currentScene.init();
}

export function updateActiveScene(dt: number) {
    if (!globals.currentScene) {
        return;
    }
    globals.currentScene.update(dt);
}

export function drawActiveScene() {
    if (!globals.currentScene) {
        return;
    }
    globals.currentScene.draw();
}
