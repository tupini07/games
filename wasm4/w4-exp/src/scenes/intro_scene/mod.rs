use crate::{
    scene_manager::{GameStates, Scene},
    w4utils::{
        controller::{self, Keys},
        graphics,
    },
    wasm4::*,
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
            graphics::set_draw_color(graphics::DrawColors::Color3);
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
        text("Hello from Rust!", 10, 10);

        blit(&SMILEY, 76, 76, 8, 8, BLIT_1BPP);
        text("Press X to continue", 8, 90);
    }
}
