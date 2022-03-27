use std::ops::Range;

use w4utils::graphics::{shapes, DrawColors};

#[derive(Debug)]
pub struct Snowflake {
    x: i32,
    y: i32,
    vx: i32,
    vy: i32,
    size: u32,
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
            x: rand_range_i32(rng, 0..160),
            y: rand_range_i32(rng, 0..160),
            vx: rand_range_i32(rng, 2..7),
            vy: rand_range_i32(rng, 2..4),
            size: rng.rand_range(1..5),
        }
    }

    pub fn update(&mut self) {
        self.x += self.vx;
        self.y += self.vy;

        if self.x > 160 {
            self.x = 0;
        } else if self.x < 0 {
            self.x = 160;
        }

        if self.y > 160 {
            self.y = 0;
        }
    }

    pub fn draw(&self) {
        shapes::circle(self.x, self.y, self.size, DrawColors::Color4);
    }
}
