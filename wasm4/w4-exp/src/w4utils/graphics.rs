use crate::wasm4::*;

pub enum DrawColors {
    Color1,
    Color2,
    Color3,
    Color4,
}

pub fn set_palette(palette: [u32; 4]) {
    unsafe {
        *PALETTE = palette;
    }
}

pub fn set_draw_color(color: DrawColors) {
    let c = match color {
        DrawColors::Color1 => 1,
        DrawColors::Color2 => 2,
        DrawColors::Color3 => 3,
        DrawColors::Color4 => 4,
    };

    set_draw_color_raw(c);
}

pub fn set_draw_color_raw(color: u16) {
    unsafe { *DRAW_COLORS = color }
}
