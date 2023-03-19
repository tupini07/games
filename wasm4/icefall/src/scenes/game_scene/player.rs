use w4utils::{
    controller::{self, Keys},
    graphics,
};

use crate::{assets, common::vector2d::Vector2d, wasm4};

const X_SPEED: i32 = 5;

struct SkateMark {
    pos: Vector2d<i32>,
    pub lifetime: u32,
}

impl SkateMark {
    pub fn new(pl: &Player) -> SkateMark {
        SkateMark {
            pos: Vector2d::new(pl.pos.x + 8, pl.pos.y + 16),
            lifetime: 20,
        }
    }

    pub fn update(&mut self) {
        self.lifetime -= 1;
    }

    pub fn draw(&self) {
        graphics::shapes::line(
            self.pos.x,
            self.pos.y,
            self.pos.x,
            self.pos.y,
            graphics::DrawColors::Color4,
        );
    }
}

pub struct Player {
    pub pos: Vector2d<i32>,
    vel: Vector2d<i32>,
    facing_right: bool,
    skate_marks: Vec<SkateMark>,
}

impl Player {
    pub fn new(initial_x: i32, initial_y: i32) -> Player {
        Player {
            pos: Vector2d::new(initial_x, initial_y),
            vel: Vector2d::new(0, 0),
            facing_right: true,
            skate_marks: vec![],
        }
    }

    fn handle_input(&mut self) {
        if controller::is_key_down(Keys::Left) {
            self.vel.x = -X_SPEED;
            self.facing_right = false;
        }

        if controller::is_key_down(Keys::Right) {
            self.vel.x = X_SPEED;
            self.facing_right = true;
        }
    }

    pub fn update(&mut self) {
        let potential_new_x = self.pos.x + self.vel.x;
        if potential_new_x < 0 || potential_new_x > (160 - 16) {
            self.vel.x = 0;
            self.facing_right = !self.facing_right;
        }

        self.pos.x += self.vel.x;
        if self.vel.x.abs() > 0 {
            self.skate_marks.push(SkateMark::new(self));
        }

        self.handle_input();

        for sm in &mut self.skate_marks {
            sm.update();
        }

        self.skate_marks.retain(|sm| sm.lifetime > 0);
    }

    pub fn draw(&self) {
        graphics::set_draw_color_raw(0x4320);
        let flip_flag = if self.facing_right {
            0
        } else {
            wasm4::BLIT_FLIP_X
        };

        for sm in &self.skate_marks {
            sm.draw();
        }

        graphics::set_draw_color_raw(0x4320);
        wasm4::blit(
            &assets::sprites::PLAYER,
            self.pos.x,
            self.pos.y,
            assets::sprites::PLAYER_WIDTH,
            assets::sprites::PLAYER_HEIGHT,
            assets::sprites::PLAYER_FLAGS | flip_flag,
        );

        graphics::set_draw_color_raw(0x2340);
        wasm4::blit(
            &assets::sprites::PLAYER,
            self.pos.x,
            self.pos.y + 16,
            assets::sprites::PLAYER_WIDTH,
            assets::sprites::PLAYER_HEIGHT,
            assets::sprites::PLAYER_FLAGS | flip_flag | wasm4::BLIT_FLIP_Y,
        );
    }
}
