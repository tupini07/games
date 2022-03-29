#![feature(int_roundings)]

#[cfg(feature = "buddy-alloc")]
mod alloc;
mod wasm4;

use scene_manager::{GameStates, Scene};
use scenes::game_scene::GameScene;
use scenes::intro_scene::IntroScene;

use crate::scene_manager::SceneManager;

mod assets;
mod common;
mod constants;
mod scene_manager;
mod scenes;

static mut CURRENT_SCENE: GameStates = GameStates::TITLE;

// TODO: is there a better way to avoid boxing here?
// previous idea was using a 'current_scene' inside the SceneManager struct
// which would hold a Box<dyn Scene>, but that implies we need to always box
// current scene (which is maybe not so bad?)
static mut INTRO_SCENE: Option<IntroScene> = None;
static mut GAME_SCENE: Option<GameScene> = None;

#[no_mangle]
fn start() {
    w4utils::graphics::set_palette([0x002b59, 0x005f8c, 0x00b9be, 0x9ff4e5]);
    unsafe {
        INTRO_SCENE = Some(IntroScene::new());
    }
}

#[no_mangle]
fn update() {
    // w4utils::graphics::clear_screen(w4utils::graphics::DrawColors::Color1);
    w4utils::graphics::reset_draw_colors();

    unsafe {
        let new_scene_opt: Option<GameStates> = match CURRENT_SCENE {
            GameStates::TITLE => SceneManager::do_tick(&mut INTRO_SCENE),
            GameStates::GAME => SceneManager::do_tick(&mut GAME_SCENE),
        };

        if let Some(new_scene) = new_scene_opt {
            if constants::DEV_MODE {
                wasm4::trace(format!("Changing scene to {:?}", new_scene));
            }

            // destructure current scene
            match CURRENT_SCENE {
                GameStates::TITLE => INTRO_SCENE = None,
                GameStates::GAME => GAME_SCENE = None,
            }

            CURRENT_SCENE = new_scene;

            // initialize new scene
            match CURRENT_SCENE {
                GameStates::TITLE => INTRO_SCENE = Some(IntroScene::new()),
                GameStates::GAME => GAME_SCENE = Some(GameScene::new()),
            }
        }
    }

    // w4utils::graphics::set_draw_color_raw(0x4320);
    // wasm4::blit(
    //     &assets::sprites::PLAYER,
    //     20,
    //     135,
    //     assets::sprites::PLAYER_WIDTH,
    //     assets::sprites::PLAYER_HEIGHT,
    //     assets::sprites::PLAYER_FLAGS,
    // );

    // // draw a color 2 box
    // w4utils::graphics::set_draw_colors(w4utils::graphics::DrawColors::Color2);
    // const ARR_SIZE: usize = 100_usize.div_ceil(8_usize); // 8 pixels per u8
    // let ss: [u8; ARR_SIZE] = [0b00000000; ARR_SIZE];
    // wasm4::blit(&ss, 100, 100, 10, 10, wasm4::BLIT_1BPP);

    // // draw rect
    // w4utils::graphics::shapes::rect_with_outline(
    //     50,
    //     50,
    //     20,
    //     20,
    //     w4utils::graphics::DrawColors::Color4,
    //     w4utils::graphics::DrawColors::Color3,
    // );

    // w4utils::graphics::shapes::circle_with_outline(
    //     60,
    //     60,
    //     14,
    //     w4utils::graphics::DrawColors::Color2,
    //     w4utils::graphics::DrawColors::Color4,
    // );

    // w4utils::graphics::shapes::line(10, 140, 145, 145, w4utils::graphics::DrawColors::Color4);

    // w4utils::graphics::shapes::text(
    //     "potato man!",
    //     10,
    //     130,
    //     w4utils::graphics::DrawColors::Color2,
    // );
    w4utils::controller::update_controller();
}
