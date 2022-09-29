use w4utils::{
    controller::{self, Keys},
    graphics,
};

use crate::{
    assets,
    common::snowflakes::Snowflake,
    scene_manager::{GameStates, Scene},
    wasm4::{self},
};

use self::{clouds::Cloud, falling_block::FallingBlock, player::Player};

mod clouds;
mod falling_block;
mod player;

const SPAWN_BLOCK_INITIAL_TIMER: u32 = 300;

pub struct GameScene {
    clouds: Vec<Cloud>,
    falling_blocks: Vec<FallingBlock>,
    passed_blocks: u32,
    player: Player,
    rng: oorandom::Rand32,
    snowflakes: Vec<Snowflake>,
    spawn_block_timer: u32,
    spawn_block_timer_speed: f32,
}

impl Scene for GameScene {
    fn new() -> GameScene {
        let mut rng = oorandom::Rand32::new(42);
        GameScene {
            clouds: Cloud::make_clouds(&mut rng),
            falling_blocks: vec![],
            passed_blocks: 0,
            player: Player::new(160 / 2, 160 - 26),
            rng,
            snowflakes: Snowflake::make_snowflake_vec(7, &mut rng),
            spawn_block_timer: 70,
            spawn_block_timer_speed: 1.0,
        }
    }

    fn update(&mut self) -> Option<GameStates> {
        self.player.update();

        if controller::is_key_just_pressed(Keys::Z) {
            return Some(GameStates::TITLE);
        }

        for block in &mut self.falling_blocks {
            block.update();
            if block.collidable && block.pos.y > 145 {
                block.collidable = false;
                self.passed_blocks += 1;
            }
        }

        for flake in &mut self.snowflakes {
            flake.update();
        }

        for cloud in &mut self.clouds {
            cloud.update(&mut self.rng);
        }

        self.spawn_block_timer -= self.spawn_block_timer_speed as u32;
        if self.spawn_block_timer <= 0 {
            self.spawn_block_timer = SPAWN_BLOCK_INITIAL_TIMER;
            self.falling_blocks
                .push(FallingBlock::spawn_random_block(&mut self.rng));

            // increase timer speed
            if self.spawn_block_timer_speed < 6.0 {
                self.spawn_block_timer_speed += 0.1;
                wasm4::trace(format!("new spawn speed: {}", self.spawn_block_timer_speed));
            }
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

        for block in &self.falling_blocks {
            block.draw();
        }

        for cloud in &self.clouds {
            cloud.draw();
        }

        for flake in &self.snowflakes {
            flake.draw();
        }

        // draw score
        graphics::shapes::rect(1, 1, 76, 12, w4utils::graphics::DrawColors::Color4);
        graphics::shapes::rect(2, 2, 74, 10, w4utils::graphics::DrawColors::Color3);

        graphics::set_primary_color(w4utils::graphics::DrawColors::Color1);
        graphics::set_secondary_color(w4utils::graphics::DrawColors::Color2);
        wasm4::text(format!("Score: {: >2}", self.passed_blocks), 3, 3);
    }
}
