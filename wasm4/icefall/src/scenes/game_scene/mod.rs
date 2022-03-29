use w4utils::controller::{self, Keys};

use crate::{
    assets,
    common::snowflakes::Snowflake,
    scene_manager::{GameStates, Scene},
    wasm4::{self},
};

use self::player::Player;

mod player;

pub struct GameScene {
    player: Player,
    rng: oorandom::Rand32,
    snowflakes: Vec<Snowflake>,
}

impl Scene for GameScene {
    fn new() -> GameScene {
        let mut rng = oorandom::Rand32::new(42);
        GameScene {
            player: Player::new(160 / 2, 160 - 26),
            snowflakes: Snowflake::make_snowflake_vec(7, &mut rng),
            rng,
        }
    }

    fn update(&mut self) -> Option<GameStates> {
        self.player.update();

        if controller::is_key_just_pressed(Keys::Z) {
            return Some(GameStates::TITLE);
        }

        for flake in &mut self.snowflakes {
            flake.update();
        }

        return None;
    }

    fn draw(&self) {
        wasm4::blit(
            &assets::sprites::BACKGROUND1,
            0,
            0,
            assets::sprites::BACKGROUND1_WIDTH,
            assets::sprites::BACKGROUND1_HEIGHT,
            assets::sprites::BACKGROUND1_FLAGS,
        );

        self.player.draw();

        for flake in &self.snowflakes {
            flake.draw();
        }
    }
}
