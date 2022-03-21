use crate::wasm4::*;

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

pub fn set_draw_color(color: DrawColors) {
    set_draw_color_raw(color.into());
}

pub fn set_draw_color_raw(color: u16) {
    unsafe { *DRAW_COLORS = color }
}
