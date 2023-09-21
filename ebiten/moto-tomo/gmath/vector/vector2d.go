package vector

import (
	"fmt"
	"math"
)

type Vector2 struct {
	X float64
	Y float64
}

func NewVector2(x float64, y float64) Vector2 {
	return Vector2{x, y}
}

func Zero() Vector2 {
	return Vector2{X: 0, Y: 0}
}

func (v Vector2) String() string {
	return fmt.Sprintf("(%f, %f)", v.X, v.Y)
}

func (v Vector2) Equals(other Vector2) bool {
	return v.X == other.X && v.Y == other.Y
}

func (v Vector2) Add(other Vector2) Vector2 {
	return Vector2{v.X + other.X, v.Y + other.Y}
}

func (v Vector2) Subtract(other Vector2) Vector2 {
	return Vector2{v.X - other.X, v.Y - other.Y}
}

func (v Vector2) Multiply(scalar float64) Vector2 {
	return Vector2{v.X * scalar, v.Y * scalar}
}

func (v Vector2) Magnitude() float64 {
	return math.Sqrt(v.X*v.X + v.Y*v.Y)
}

func (v Vector2) Normalize() Vector2 {
	mag := v.Magnitude()
	if mag == 0 {
		return Vector2{}
	}
	return Vector2{v.X / mag, v.Y / mag}
}
