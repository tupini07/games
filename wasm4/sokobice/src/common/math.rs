pub fn clamp<T: PartialOrd>(val: T, min: T, max: T) -> T {
    if val > max {
        return max;
    }

    if val < min {
        return min;
    }

    return val;
}
