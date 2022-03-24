use crate::wasm4::*;

#[derive(Clone, Copy)]
pub enum DrawColors {
    Color1,
    Color2,
    Color3,
    Color4,
}

impl From<u16> for DrawColors {
    fn from(item: u16) -> Self {
        match item {
            1 => DrawColors::Color1,
            2 => DrawColors::Color2,
            3 => DrawColors::Color3,
            4 => DrawColors::Color4,
            _ => unreachable!(),
        }
    }
}

impl From<DrawColors> for u16 {
    fn from(item: DrawColors) -> Self {
        match item {
            DrawColors::Color1 => 1,
            DrawColors::Color2 => 2,
            DrawColors::Color3 => 3,
            DrawColors::Color4 => 4,
        }
    }
}

pub fn set_palette(palette: [u32; 4]) {
    unsafe {
        *PALETTE = palette;
    }
}

pub fn clear_screen(color: DrawColors) {
    let color_num_u16: u16 = color.into();
    let color_num: u8 = color_num_u16.try_into().unwrap();

    unsafe {
        (&mut *FRAMEBUFFER)
            .fill(color_num | (color_num << 2) | (color_num << 4) | (color_num << 6));
    }
}

pub fn set_draw_colors(color: DrawColors) {
    set_draw_color_raw(color.into());
}

pub fn reset_draw_colors() {
    set_draw_color_raw(0x4321);
}

pub fn set_draw_color_raw(color: u16) {
    unsafe { *DRAW_COLORS = color }
}

fn set_color_at(at: DrawColors, color: DrawColors) {
    let padding = match at {
        DrawColors::Color1 => 0,
        DrawColors::Color2 => 4,
        DrawColors::Color3 => 8,
        DrawColors::Color4 => 12,
    };

    let canceller = !(0b1111 << padding);
    let target_color: u16 = color.into();

    unsafe { *DRAW_COLORS = ((*DRAW_COLORS) & canceller) | (target_color << padding) }
}

pub fn set_primary_color(color: DrawColors) {
    set_color_at(DrawColors::Color1, color);
}

pub fn set_secondary_color(color: DrawColors) {
    set_color_at(DrawColors::Color2, color);
}
