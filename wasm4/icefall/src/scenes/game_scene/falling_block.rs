use oorandom::Rand32;
use w4utils::graphics;

use crate::{assets, common::vector2d::Vector2d, wasm4};

const BLOCK_UPDATE_TIME: u32 = 2;

pub struct FallingBlock {
    pub pos: Vector2d<u32>,
    vel: u32,
    time_to_update: u32,
    pub collidable: bool,
}

impl FallingBlock {
    pub fn spawn_random_block(rng: &mut Rand32) -> FallingBlock {
        FallingBlock {
            pos: Vector2d::new(
                rng.rand_range(5..(160 - assets::sprites::BLOCK1_WIDTH - 5)),
                10,
            ),
            vel: rng.rand_range(1..3),
            time_to_update: rng.rand_range(1..BLOCK_UPDATE_TIME),
            collidable: true,
        }
    }

    pub fn update(&mut self) {
        self.time_to_update -= 1;
        if self.time_to_update <= 0 {
            self.pos.y += self.vel;
            self.time_to_update = BLOCK_UPDATE_TIME;
        }
    }

    pub fn draw(&self) {
        graphics::set_draw_color_raw(0x4320);
        wasm4::blit(
            &assets::sprites::BLOCK1,
            self.pos.x as i32,
            self.pos.y as i32,
            assets::sprites::BLOCK1_WIDTH,
            assets::sprites::BLOCK1_HEIGHT,
            assets::sprites::BLOCK1_FLAGS,
        );
    }

    pub fn is_colliding_with_vector(&self, pos: &Vector2d<i32>) -> bool {
        return pos.x >= self.pos.x as i32
            && pos.x <= (self.pos.x + assets::sprites::BLOCK1_WIDTH) as i32
            && pos.y >= self.pos.y as i32
            && pos.y <= (self.pos.y + assets::sprites::BLOCK1_HEIGHT) as i32;
    }
}
