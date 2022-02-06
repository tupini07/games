package main

import (
	"fmt"
	"math/rand"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/jakecoffman/cp"
	"golang.org/x/image/colornames"
)

type RectShape struct {
	width, height float64
}

type StackBlock struct {
	body   *cp.Body
	shape  *cp.Shape
	rShape RectShape
}

func (s *StackBlock) DrawBlock(screen *ebiten.Image) {
	pos := s.body.Position()
	shape := s.rShape

	fmt.Printf("%#v\n", pos)

	ebitenutil.DrawRect(screen,
		pos.X, pos.Y,
		shape.width,
		shape.height,
		colornames.Navajowhite)
}

func MakeRandomBlock(space *cp.Space) StackBlock {
	boxWidth := float64(5 + rand.Intn(ScreenWidth/5))
	boxHeights := float64(5 + rand.Intn(ScreenWidth/5))

	boxBody := space.AddBody(cp.NewBody(10, cp.INFINITY))
	boxBody.SetPosition(cp.Vector{
		X: float64(rand.Intn(ScreenWidth)),
		Y: float64(rand.Intn(ScreenHeight)),
	})
	boxBody.SetVelocity(0, 0)

	boxShape := space.AddShape(cp.NewBox(boxBody, boxWidth, boxHeights, 0))
	boxShape.SetElasticity(1)
	boxShape.SetFriction(cp.INFINITY)

	return StackBlock{
		body:  boxBody,
		shape: boxShape,
		rShape: RectShape{
			width:  boxWidth,
			height: boxHeights,
		},
	}
}
