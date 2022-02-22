package main

import (
	"log"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"golang.org/x/image/colornames"
)

type Direction int

const (
	DIR_LEFT Direction = iota
	DIR_RIGHT
)

type Altitude int

const (
	ALTITUDE_HIGH Altitude = iota
	ALTITUDE_MID
	ALTITUDE_LOW
)

func shootArrow(dir Direction, alt Altitude) {
	var dx float64

	switch dir {
	case DIR_LEFT:
		log.Print("make arrow to the left")
		dx = -1
	case DIR_RIGHT:
		log.Print("make arrow to the right")
		dx = 1
	}

	addProcess(&Arrow{
		x:  ScreenWidth / 2,
		y:  ScreenHeight / 2,
		dx: dx,
	})
}

type Arrow struct {
	x, y, dx float64
}

func (a *Arrow) update(dt float64) {
	a.x += a.dx
	if a.x > ScreenWidth {
		removeProcess(a)
	}
}

func (a *Arrow) draw(screen *ebiten.Image) {
	ebitenutil.DrawRect(screen, a.x, a.y, 10, 10, colornames.Red)
}
