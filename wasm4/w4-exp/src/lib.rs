#[cfg(feature = "buddy-alloc")]
mod alloc;
mod wasm4;
use w4utils::controller::Keys;
use wasm4::*;

mod w4utils;

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

#[no_mangle]
fn start() {
    w4utils::graphics::set_palette([0xfbf7f3, 0xe5b083, 0x426e5d, 0x20283d]);
}

#[no_mangle]
fn update() {
    w4utils::graphics::set_draw_color(w4utils::graphics::DrawColors::Color2);
    text("Hello from Rust!", 10, 10);

    if w4utils::controller::is_key_down(Keys::X) {
        w4utils::graphics::set_draw_color(w4utils::graphics::DrawColors::Color3);
    }

    if w4utils::controller::is_key_just_pressed(Keys::Left) {
        trace("Just pressed LEFT key this frame!");
    }

    blit(&SMILEY, 76, 76, 8, 8, BLIT_1BPP);
    text("Press X to continue", 8, 90);

    w4utils::controller::update_controller();
}
