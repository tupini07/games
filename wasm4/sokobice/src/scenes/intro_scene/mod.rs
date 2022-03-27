use w4utils::{
    controller::{self, Keys},
    graphics,
};

use crate::{
    scene_manager::{GameStates, Scene},
    wasm4::{self, *}, assets,
};

pub struct IntroScene {
    posx: f32,
    posy: f32,
    radius: f32,
    going_under: bool,
}

#[rustfmt::skip]
const SMILEY: [u8; 8] = [
    0b11000011,
    0b10000001,
    0b00100100,
    0b00100100,
    0b00000000,
    0b00100100,
    0b10011001,
    0b11000011,
];

impl Scene for IntroScene {
    fn new() -> IntroScene {
        IntroScene {
            posx: 0.0,
            posy: 0.0,
            radius: 15.0,
            going_under: true,
        }
    }

    fn update(&mut self) -> Option<GameStates> {
        if controller::is_key_down(Keys::X) {
            graphics::set_draw_color_raw(0x1234);
        }

        if controller::is_key_just_pressed(Keys::Left) {
            trace("Just pressed LEFT key this frame!");
        }

        if controller::is_key_just_pressed(Keys::Z) {
            trace("changing to another scene!");
            return Some(GameStates::TITLE);
        }

        return None;
    }

    fn draw(&self) {
        fn draw_block(color: u8, x: i32, y: i32) {
            let colors = [color | (color << 2) | (color << 4) | (color << 6); 16];
            blit(&colors, x, y, 8, 8, BLIT_2BPP);
        }

        draw_block(1, 0, 0);
        draw_block(0, 1, 0);

        draw_block(1, 9, 0);

        draw_block(2, 18, 0);

        draw_block(3, 27, 0);

        // text("Hello from Rust!", 10, 10);
        /*
        000100100011 < DRAW_COLORS
        10101010 <<

        */
        // blit(&SMILEY, 76, 76, 8, 8, BLIT_1BPP);
        // text("Press X to continue", 8, 90);

        wasm4::blit(
            &assets::sprites::BACKGROUND1,
            0,
            0,
            assets::sprites::BACKGROUND1_WIDTH,
            assets::sprites::BACKGROUND1_HEIGHT,
            assets::sprites::BACKGROUND1_FLAGS,
        );
    }
}
