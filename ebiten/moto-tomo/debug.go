package main

import (
	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/vector"
	"github.com/solarlune/resolv"
	"github.com/tupini07/moto-tomo/constants"
	"golang.org/x/image/colornames"
)

func DrawObjCollider(screen *ebiten.Image, obj *resolv.Object) {
	if constants.Debug && constants.DrawColliders {
		// draw green rectangle outline for the object
		transparentGreen := colornames.Green
		transparentGreen.A = 0x10

		vector.DrawFilledRect(
			screen,
			float32(obj.X),
			float32(obj.Y),
			float32(obj.W),
			float32(obj.H),
			transparentGreen,
			false,
		)
	}
}
