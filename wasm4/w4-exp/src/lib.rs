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
    wasm4::blit(&[1; 160^2], 0, 0, 160, 160, wasm4::BLIT_1BPP);

    // w4utils::graphics::set_draw_color(w4utils::graphics::DrawColors::Color2);

    unsafe {
        if let Some(sm) = &mut SCENE_MANAGER {
            sm.update();
            sm.draw();
        }
    }

    wasm4::blit(
        &assets::sprites::sprites::PLAYER,
        20,
        20,
        16,
        16,
        wasm4::BLIT_2BPP,
    );

    w4utils::controller::update_controller();
}
