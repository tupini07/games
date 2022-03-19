#![feature(int_roundings)]

#[cfg(feature = "buddy-alloc")]
mod alloc;
mod wasm4;

use scene_manager::SceneManager;

mod assets;
mod scene_manager;
mod scenes;
mod w4utils;

static mut SCENE_MANAGER: Option<SceneManager> = None;

#[no_mangle]
fn start() {
    w4utils::graphics::set_palette([0x002b59, 0x005f8c, 0x00b9be, 0x9ff4e5]);

    unsafe {
        SCENE_MANAGER = Some(SceneManager::new());
    }
}

#[no_mangle]
fn update() {
    w4utils::graphics::set_draw_color_raw(0x1234);

    // w4utils::graphics::clear_screen(w4utils::graphics::DrawColors::Color1);

    unsafe {
        if let Some(sm) = &mut SCENE_MANAGER {
            sm.update();
            sm.draw();
        }
    }

    wasm4::blit(
        &assets::sprites::PLAYER,
        20,
        20,
        16,
        16,
        wasm4::BLIT_2BPP,
    );

    // draw a color 2 box
    w4utils::graphics::set_draw_color(w4utils::graphics::DrawColors::Color2);
    const arr_size: usize = 100_usize.div_ceil(8_usize); // 8 pixels per u8
    let ss: [u8; arr_size] = [0b00000000; arr_size];
    wasm4::blit(&ss, 100, 100, 10, 10, wasm4::BLIT_1BPP);

    w4utils::controller::update_controller();
}
