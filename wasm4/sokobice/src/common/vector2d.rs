#[derive(Debug, Clone)]
pub struct Vector2d<T> {
    pub x: T,
    pub y: T,
}

impl<T: PartialOrd> Vector2d<T> {
    pub fn new(x: T, y: T) -> Vector2d<T> {
        Vector2d { x, y }
    }
}
