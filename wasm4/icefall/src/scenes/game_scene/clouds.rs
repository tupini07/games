use oorandom::Rand32;
use w4utils::graphics;

use crate::{
    assets,
    common::{math, vector2d::Vector2d},
    wasm4,
};

const CLOUD_UPDATE_TIME: u32 = 60;

pub struct Cloud {
    pos: Vector2d<u32>,
    time_to_update: u32,
    minor_pos: Vector2d<u32>,
    max_pos: Vector2d<u32>,
}

impl Cloud {
    fn new(x: u32, y: u32, rng: &mut Rand32) -> Cloud {
        Cloud {
            pos: Vector2d::new(x, y),
            time_to_update: rng.rand_range(5..CLOUD_UPDATE_TIME),
            minor_pos: Vector2d::new(
                math::clamp(x as i32 - 5, 1, 160) as u32,
                math::clamp(y as i32 - 5, 1, 160) as u32,
            ),
            max_pos: Vector2d::new(x + 5, y + 5),
        }
    }

    pub fn make_clouds(rng: &mut Rand32) -> Vec<Cloud> {
        vec![
            Cloud::new(0, 0, rng),
            Cloud::new(50, 0, rng),
            Cloud::new(110, 0, rng),
        ]
    }

    pub fn update(&mut self, rng: &mut Rand32) {
        self.time_to_update -= 1;
        if self.time_to_update <= 0 {
            self.time_to_update = CLOUD_UPDATE_TIME;

            let x_var = rng.rand_range(0..3) as i32 - 1;
            let y_var = rng.rand_range(0..3) as i32 - 1;

            let new_x = self.pos.x as i32 + x_var;
            let new_y = self.pos.y as i32 + y_var;

            self.pos.x = math::clamp(new_x, self.minor_pos.x as i32, self.max_pos.x as i32) as u32;
            self.pos.y = math::clamp(new_y, self.minor_pos.y as i32, self.max_pos.y as i32) as u32;
        }
    }

    pub fn draw(&self) {
        graphics::set_draw_color_raw(0x4320);
        wasm4::blit(
            &assets::sprites::CLOUD,
            self.pos.x as i32,
            self.pos.y as i32,
            assets::sprites::CLOUD_WIDTH,
            assets::sprites::CLOUD_HEIGHT,
            assets::sprites::CLOUD_FLAGS,
        );
    }
}
