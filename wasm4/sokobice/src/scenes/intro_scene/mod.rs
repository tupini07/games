use w4utils::{
    controller::{self, Keys},
    graphics::{self, DrawColors},
};

use crate::{
    assets,
    scene_manager::{GameStates, Scene},
    wasm4::{self, *}, constants,
};

mod snowflakes;

use self::snowflakes::Snowflake;

pub struct IntroScene {
    snowflakes: Vec<Snowflake>,
    rng: oorandom::Rand32
}

impl Scene for IntroScene {
    fn new() -> IntroScene {
        let mut rng = oorandom::Rand32::new(42);
        IntroScene {
            snowflakes: Snowflake::make_snowflake_vec(30, &mut rng),
            rng
        }
    }

    fn update(&mut self) -> Option<GameStates> {
        if controller::is_key_down(Keys::X) {
            graphics::set_draw_color_raw(0x1234);
        }

        if controller::is_key_down(Keys::Right) {
            if self.snowflakes.len() < 200 {
                self.snowflakes.push(Snowflake::new(&mut self.rng));
            }
        }

        if controller::is_key_down(Keys::Left) {
            if self.snowflakes.len() > 5 {
                self.snowflakes.pop().expect("expected there to be flakes in the vector");
            }
        }

        if controller::is_key_just_pressed(Keys::Z) {
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

        graphics::shapes::text("Ice Fall", 15, 15, DrawColors::Color2);
        graphics::shapes::text("Press Z to play", 17, 27, DrawColors::Color4);

        for flake in &self.snowflakes {
            flake.draw();
        }
    }
}
