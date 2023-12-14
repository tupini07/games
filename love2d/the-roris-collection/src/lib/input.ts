import { KeyConstant } from "love.keyboard";

export class MouseActionLocation {
    constructor(
        public x: number,
        public y: number,
        public button: number,
    ) {}
}

let just_pressed_keys: KeyConstant[] = [];
let just_released_keys: KeyConstant[] = [];
let just_pressed_mouse_buttons: MouseActionLocation[] = [];
let just_released_mouse_buttons: MouseActionLocation[] = [];

export function updateInput(): void {
    just_pressed_keys = [];
    just_released_keys = [];
    just_pressed_mouse_buttons = [];
    just_released_mouse_buttons = [];
}

export function keypressed(key: KeyConstant): void {
    just_pressed_keys.push(key);
}

export function keyreleased(key: KeyConstant): void {
    just_released_keys.push(key);
}

export function mousepressed(
    x: number,
    y: number,
    button: number,
    istouch: boolean,
): void {
    just_pressed_mouse_buttons.push(new MouseActionLocation(x, y, button));
}

export function mousereleased(
    x: number,
    y: number,
    button: number,
    istouch: boolean,
): void {
    just_released_mouse_buttons.push(new MouseActionLocation(x, y, button));
}

export function isKeyDown(key: KeyConstant): boolean {
    return love.keyboard.isDown(key);
}

export function isKeyPressed(key: KeyConstant): boolean {
    return just_pressed_keys.includes(key);
}

export function isKeyReleased(key: KeyConstant): boolean {
    return just_released_keys.includes(key);
}

export function isMouseDown(button: number): boolean {
    return love.mouse.isDown(button);
}

export function isMousePressed(
    button: number,
): MouseActionLocation | undefined {
    return just_pressed_mouse_buttons.find((m) => m.button === button);
}

export function isMouseReleased(
    button: number,
): MouseActionLocation | undefined {
    return just_released_mouse_buttons.find((m) => m.button === button);
}
