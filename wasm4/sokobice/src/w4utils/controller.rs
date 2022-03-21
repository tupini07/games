use crate::wasm4::*;

static mut PREVIOUS_GAMEPAD: u8 = 0;

pub enum Keys {
    X,
    Z,
    Up,
    Down,
    Left,
    Right,
}

pub fn is_key_down(key: Keys) -> bool {
    let gamepad = unsafe { *GAMEPAD1 };

    let k = match key {
        Keys::X => BUTTON_1,
        Keys::Z => BUTTON_2,
        Keys::Up => BUTTON_UP,
        Keys::Down => BUTTON_DOWN,
        Keys::Left => BUTTON_LEFT,
        Keys::Right => BUTTON_RIGHT,
    };

    return gamepad & k != 0;
}

pub fn update_controller() {
    unsafe {
        let gamepad = *GAMEPAD1;
        PREVIOUS_GAMEPAD = gamepad;
    };
}

pub fn is_key_just_pressed(key: Keys) -> bool {
    let k = match key {
        Keys::X => BUTTON_1,
        Keys::Z => BUTTON_2,
        Keys::Up => BUTTON_UP,
        Keys::Down => BUTTON_DOWN,
        Keys::Left => BUTTON_LEFT,
        Keys::Right => BUTTON_RIGHT,
    };

    // obtained by XOring the current and previous gamepad states
    let just_pressed = unsafe {
        let gamepad = *GAMEPAD1;
        gamepad & (gamepad ^ PREVIOUS_GAMEPAD)
    };

    return just_pressed & k != 0;
}
