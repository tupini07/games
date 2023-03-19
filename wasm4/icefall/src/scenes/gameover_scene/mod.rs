use w4utils::{
    controller::{self, Keys},
    graphics::{self, shapes, DrawColors},
};

use crate::{
    assets,
    common::snowflakes::Snowflake,
    constants,
    scene_manager::{GameStates, Scene},
    wasm4::{self},
};

pub struct GameOverScene {
    rng: oorandom::Rand32,
    snowflakes: Vec<Snowflake>,
    switching_scene: bool,
    switching_scene_progress: f32,
}

impl Scene for GameOverScene {
    fn new() -> GameOverScene {
        let mut rng = oorandom::Rand32::new(42);
        GameOverScene {
            snowflakes: Snowflake::make_snowflake_vec(30, &mut rng),
            rng,
            switching_scene: false,
            switching_scene_progress: 0.0,
        }
    }

    fn update(&mut self) -> Option<GameStates> {
        if self.switching_scene {
            graphics::set_draw_color_raw(0x1234);

            self.switching_scene_progress += 0.4;
            if self.snowflakes.len() < 200 {
                self.snowflakes.push(Snowflake::new(&mut self.rng));
                self.snowflakes.push(Snowflake::new(&mut self.rng));
                self.snowflakes.push(Snowflake::new(&mut self.rng));
            }

            if constants::DEV_MODE {
                // don't wait for switching anim unless we need to
                self.switching_scene_progress = 100.0;
            }
        }

        if controller::is_key_down(Keys::Z) {
            self.switching_scene = true;
        }

        if controller::is_key_down(Keys::Right) {
            if self.snowflakes.len() < 200 {
                self.snowflakes.push(Snowflake::new(&mut self.rng));
            }
        }

        if controller::is_key_down(Keys::Left) {
            if self.snowflakes.len() > 5 {
                self.snowflakes
                    .pop()
                    .expect("expected there to be flakes in the vector");
            }
        }

        if self.switching_scene_progress >= 100.0 {
            return Some(GameStates::GAME);
        }

        for flake in &mut self.snowflakes {
            flake.update();
        }

        return None;
    }

    fn draw(&self) {
        wasm4::blit(
            &assets::sprites::TITLE_BACKGROUND,
            0,
            0,
            assets::sprites::TITLE_BACKGROUND_WIDTH,
            assets::sprites::TITLE_BACKGROUND_HEIGHT,
            assets::sprites::TITLE_BACKGROUND_FLAGS,
        );

        graphics::shapes::text("Game Over!", 15, 15, DrawColors::Color2);
        graphics::shapes::text("Press Z to play", 17, 27, DrawColors::Color4);

        for flake in &self.snowflakes {
            flake.draw();
        }

        shapes::rect(
            0,
            160 - (130.0 * (self.switching_scene_progress / 100.0)) as i32,
            160,
            160,
            DrawColors::Color4,
        );
    }
}
