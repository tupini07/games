pub const Vector2 = struct {
    x: i32,
    y: i32,

    pub fn mul(self: *Vector2, other: *Vector2) Vector2 {
        return Vector2{
            .x = self.x * other.x,
            .y = self.y * other.y,
        };
    }

    pub fn mul_scalar(self: *Vector2, scalar: i32) Vector2 {
        return Vector2{
            .x = self.x * scalar,
            .y = self.y * scalar,
        };
    }
};
