#[cfg(feature = "buddy-alloc")]
mod alloc;
mod wasm4;
use scene_manager::{Scene, SceneManager};

mod scene_manager;
mod scenes;
mod w4utils;

static mut SCENE_MANAGER: Option<SceneManager> = None;

#[no_mangle]
fn start() {
    w4utils::graphics::set_palette([0xfbf7f3, 0xe5b083, 0x426e5d, 0x20283d]);

    unsafe {
        SCENE_MANAGER = Some(SceneManager::new());
    }
}

#[no_mangle]
fn update() {
    w4utils::graphics::set_draw_color(w4utils::graphics::DrawColors::Color2);

    unsafe {
        if let Some(sm) = &mut SCENE_MANAGER {
            sm.update();
            sm.draw();
        }
    }

    w4utils::controller::update_controller();
}
