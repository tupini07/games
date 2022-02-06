package main

import (
	"math/rand"

	"github.com/hajimehoshi/ebiten/v2"
)

type Position struct {
	x, y int
}

type RectShape struct {
	width, height int
}

type StackBlock struct {
	pos   Position
	shape RectShape
}

func (s *StackBlock) DrawBlock(screen *ebiten.Image) {
}

func MakeRandomBlock() StackBlock {
	return StackBlock{
		pos: Position{
			x: ScreenWidth,
			y: ScreenHeight / 2,
		},
		shape: RectShape{
			width:  1 + rand.Intn(10),
			height: 1 + rand.Intn(10),
		},
	}
}
