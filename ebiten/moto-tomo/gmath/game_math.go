package gmath

import "cmp"

func Clamp[T cmp.Ordered](v, min, max T) T {
	if v < min {
		return min
	}

	if v > max {
		return max
	}

	return v
}
