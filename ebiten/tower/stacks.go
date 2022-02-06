package main

import (
	"math/rand"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"golang.org/x/image/colornames"
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
	ebitenutil.DrawRect(screen,
		float64(s.pos.x),
		float64(s.pos.y),
		float64(s.shape.width),
		float64(s.shape.height),
		colornames.Purple)
}

func MakeRandomBlock() StackBlock {
	return StackBlock{
		pos: Position{
			x: rand.Intn(ScreenWidth),
			y: rand.Intn(ScreenHeight),
		},
		shape: RectShape{
			width:  5 + rand.Intn(ScreenWidth/5),
			height: 5 + rand.Intn(ScreenWidth/5),
		},
	}
}
