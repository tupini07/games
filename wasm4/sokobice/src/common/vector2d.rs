#[derive(Debug)]
pub struct Vector2d {
    pub x: i32,
    pub y: i32,
}

impl Vector2d {
    pub fn new(x: i32, y: i32) -> Vector2d {
        Vector2d { x, y }
    }
}
