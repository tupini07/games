export default class Vector2D {
    constructor(
        public x: number,
        public y: number,
    ) {}

    add(vector: Vector2D): Vector2D {
        return new Vector2D(this.x + vector.x, this.y + vector.y);
    }

    subtract(vector: Vector2D): Vector2D {
        return new Vector2D(this.x - vector.x, this.y - vector.y);
    }

    multiply(scalar: number): Vector2D {
        return new Vector2D(this.x * scalar, this.y * scalar);
    }

    divide(scalar: number): Vector2D {
        return new Vector2D(this.x / scalar, this.y / scalar);
    }

    length(): number {
        return Math.sqrt(this.x * this.x + this.y * this.y);
    }
}
