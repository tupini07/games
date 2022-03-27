use std::ops::Range;

use w4utils::graphics::{shapes, DrawColors};

use crate::common::vector2d::Vector2d;


#[derive(Debug)]
pub struct Snowflake {
    pos: Vector2d,
    vel: Vector2d,
    size: u32,
    lifetime: f32,
}

fn rand_range_i32(rng: &mut oorandom::Rand32, target_range: Range<i32>) -> i32 {
    let rand = rng.rand_u32();
    let perc = rand as f32 / u32::MAX as f32;
    let range_diff = target_range.end - target_range.start;

    let num_with_prec = (perc * range_diff as f32) + target_range.start as f32;
    num_with_prec as i32
}

impl Snowflake {
    pub fn make_snowflake_vec(num_flakes: u32, rng: &mut oorandom::Rand32) -> Vec<Snowflake> {
        (1..num_flakes).map(|_i| Snowflake::new(rng)).collect()
    }

    pub fn new(rng: &mut oorandom::Rand32) -> Snowflake {
        Snowflake {
            pos: Vector2d::new(rand_range_i32(rng, 0..160), rand_range_i32(rng, 0..160)),
            vel: Vector2d::new(rand_range_i32(rng, 2..7), rand_range_i32(rng, 2..4)),
            size: rng.rand_range(1..5),
            lifetime: 0.0,
        }
    }

    pub fn update(&mut self) {
        self.pos.x += self.vel.x;
        self.pos.y += self.vel.y;

        if self.pos.x > 160 {
            self.pos.x = 0;
        } else if self.pos.x < 0 {
            self.pos.x = 160;
        }

        if self.pos.y > 160 {
            self.pos.y = 0;
        }

        self.lifetime += 0.1;

        self.vel.x += self.lifetime.sin() as i32;
    }

    pub fn draw(&self) {
        shapes::circle(self.pos.x, self.pos.y, self.size, DrawColors::Color4);
    }
}
