use crate::wasm4;

use super::core::*;

pub fn rect_with_outline(
    x: i32,
    y: i32,
    width: u32,
    height: u32,
    fill_color: DrawColors,
    outline_color: DrawColors,
) {
    set_primary_color(fill_color);
    set_secondary_color(outline_color);
    wasm4::rect(x, y, width, height);
}

pub fn rect(x: i32, y: i32, width: u32, height: u32, color: DrawColors) {
    rect_with_outline(x, y, width, height, color, color);
}

pub fn circle_with_outline(
    x: i32,
    y: i32,
    rad: u32,
    fill_color: DrawColors,
    outline_color: DrawColors,
) {
    set_primary_color(fill_color);
    set_secondary_color(outline_color);
    wasm4::oval(x, y, rad, rad);
}

pub fn circle(x: i32, y: i32, rad: u32, color: DrawColors) {
    circle_with_outline(x, y, rad, color, color);
}

pub fn line(x1: i32, y1: i32, x2: i32, y2: i32, color: DrawColors) {
    set_primary_color(color);
    wasm4::line(x1, y1, x2, y2);
}

pub fn text_with_background<T: AsRef<str>>(
    text: T,
    x: i32,
    y: i32,
    foreground_color: DrawColors,
    background_color: DrawColors,
) {
    set_primary_color(foreground_color);
    set_secondary_color(background_color);
    wasm4::text(text, x, y);
}

pub fn text<T: AsRef<str>>(text: T, x: i32, y: i32, foreground_color: DrawColors) {
    set_draw_color_raw(0x0000);
    set_primary_color(foreground_color);
    wasm4::text(text, x, y);

    reset_draw_colors();
}
