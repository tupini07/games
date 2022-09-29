use std::ops::Range;

use w4utils::graphics::{shapes, DrawColors};

use crate::common::vector2d::Vector2d;

#[derive(Debug)]
pub struct Snowflake {
    pos: Vector2d<f32>,
    initial_vel: Vector2d<f32>,
    current_vel: Vector2d<f32>,
    size: u32,
    lifetime: f32,
}

fn rand_range_f32(rng: &mut oorandom::Rand32, target_range: Range<f32>) -> f32 {
    let rand = rng.rand_u32();
    let perc = rand as f32 / u32::MAX as f32;
    let range_diff = target_range.end - target_range.start;

    (perc * range_diff as f32) + target_range.start as f32
}

impl Snowflake {
    pub fn make_snowflake_vec(num_flakes: u32, rng: &mut oorandom::Rand32) -> Vec<Snowflake> {
        (1..num_flakes).map(|_i| Snowflake::new(rng)).collect()
    }

    pub fn new(rng: &mut oorandom::Rand32) -> Snowflake {
        let vel = Vector2d::new(rand_range_f32(rng, 2.0..7.0), rand_range_f32(rng, 2.0..4.0));
        Snowflake {
            pos: Vector2d::new(
                rand_range_f32(rng, 0.0..160.0),
                rand_range_f32(rng, 0.0..160.0),
            ),
            initial_vel: vel.clone(),
            current_vel: vel,
            size: rng.rand_range(1..5),
            lifetime: 0.0,
        }
    }

    pub fn update(&mut self) {
        self.pos.x += self.current_vel.x;
        self.pos.y += self.current_vel.y;

        if self.pos.x > 160.0 {
            self.pos.x = 0.0;
        } else if self.pos.x < 0.0 {
            self.pos.x = 160.0;
        }

        if self.pos.y > 160.0 {
            self.pos.y = 0.0;
        }

        self.lifetime += 0.02;

        self.current_vel.x = self.initial_vel.x / 2.0 + self.initial_vel.x * self.lifetime.sin();
    }

    pub fn draw(&self) {
        shapes::circle(
            self.pos.x as i32,
            self.pos.y as i32,
            self.size,
            DrawColors::Color4,
        );
    }
}
