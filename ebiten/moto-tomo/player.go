package main

import (
	_ "image/png"
	"log"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/solarlune/resolv"
	"github.com/tupini07/moto-tomo/gmath/vector"
)

type Player struct {
	sprite *ebiten.Image
	obj    *resolv.Object
}

func NewPlayer(space *resolv.Space) *Player {
	playerImg, _, err := ebitenutil.NewImageFromFile("assets/Dungeon/Characters/Character 01.png")

	physObj := resolv.NewObject(1, 1, 6, 8)
	space.Add(physObj)

	if err != nil {
		log.Fatalf("Could not load player image! %s", err)
	}

	return &Player{
		sprite: playerImg,
		obj:    physObj,
	}
}

func (p *Player) update(dt float64) {
	speed := 100.0
	moveVec := vector.Zero()

	if ebiten.IsKeyPressed(ebiten.KeyW) {
		moveVec.Y -= 1
	}
	if ebiten.IsKeyPressed(ebiten.KeyS) {
		moveVec.Y += 1
	}
	if ebiten.IsKeyPressed(ebiten.KeyA) {
		moveVec.X -= 1
	}
	if ebiten.IsKeyPressed(ebiten.KeyD) {
		moveVec.X += 1
	}

	if collision := p.obj.Check(moveVec.X, moveVec.Y); collision != nil {
		// If there was a collision, the "playerObj" Object can't move fully
		// to the right by 2, and Object.Check() would return a *Collision object.
		// A *Collision object contains the Objects and Cells that the calling
		// *resolv.Object ran into when it called Check().

		// To resolve (haha) this collision, we probably want to move the player into
		// contact with that Object. So, we call Collision.ContactWithObject() on the
		// first Object that we came into contact with (which is stored in the Collision).

		// Collision.ContactWithObject() will return a vector.Vector, indicating how much
		// distance to move to come into contact with the specified Object.

		// We could also come into contact with the cell to the right using
		// Collision.ContactWithCell(collision.Cells[0]).
		// dx = collision.ContactWithObject(collision.Objects[0]).X()
		log.Printf("Collision! %#v\n", collision)

	} else if moveVec.Magnitude() > 0 {
		normalizedVect := moveVec.Multiply(speed * dt).Normalize()
		p.obj.X += normalizedVect.X
		p.obj.Y += normalizedVect.Y
		p.obj.Update()
	}
}

func (p *Player) draw(screen *ebiten.Image) {
	geo := ebiten.GeoM{}
	geo.Translate(p.obj.X-2, p.obj.Y-2)
	ops := ebiten.DrawImageOptions{
		GeoM: geo,
	}
	screen.DrawImage(p.sprite, &ops)
}
