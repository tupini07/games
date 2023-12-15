import { IScene } from "./scenes/iscene";

interface Globals {
    currentScene: IScene;
    isDebug: boolean;
}

export let globals: Globals = {
    currentScene: null as any,
    isDebug: false,
}