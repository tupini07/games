package main

import (
	_ "image/png"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/solarlune/resolv"
	"github.com/tupini07/moto-tomo/gmath/vector"
	"github.com/tupini07/moto-tomo/logging"
)

type Player struct {
	sprite   *ebiten.Image
	obj      *resolv.Object
	isMoving bool
	moveVec  vector.Vector2
}

func NewPlayer(space *resolv.Space, x float64, y float64) *Player {
	playerImg, _, err := ebitenutil.NewImageFromFile("assets/Dungeon/Characters/Character 01.png")

	// physObj := resolv.NewObject(x, y, 6, 8)
	physObj := resolv.NewObject(x, y, 10, 10)
	space.Add(physObj)

	if err != nil {
		logging.Errorf("Could not load player image! %s", err)
	}

	return &Player{
		sprite:   playerImg,
		obj:      physObj,
		isMoving: false,
		moveVec:  vector.Zero(),
	}
}

func (p *Player) Update(dt float64) {
	// speed := 130.0 / 2
	speed := 90.

	if !p.isMoving {
		moveVec := vector.Zero()

		if ebiten.IsKeyPressed(ebiten.KeyW) {
			moveVec.Y = -1
		} else if ebiten.IsKeyPressed(ebiten.KeyS) {
			moveVec.Y = 1
		} else if ebiten.IsKeyPressed(ebiten.KeyA) {
			moveVec.X = -1
		} else if ebiten.IsKeyPressed(ebiten.KeyD) {
			moveVec.X = 1
		}

		moveVec = moveVec.Multiply(speed)
		if moveVec.Magnitude() > 0 {
			p.isMoving = true
			p.moveVec = moveVec
		}
	} else {
		vel_x := p.moveVec.X * dt
		vel_y := p.moveVec.Y * dt

		if collision := p.obj.Check(vel_x, vel_y); collision != nil {
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

			// log.Printf("Collision! %#v\n", collision)
			// &resolv.Collision{checkingObject:(*resolv.Object)(0xc0000b8000),
			// dx:0, dy:1, Objects:[]*resolv.Object{(*resolv.Object)(0xc0000b8600)},
			// Cells:[]*resolv.Cell{(*resolv.Cell)(0xc0003d0b40)}}

			contactWithObject := collision.ContactWithObject(collision.Objects[0])
			logging.Debugf("Contact with object: %#v \n", contactWithObject)

			vel_x = contactWithObject.X()
			vel_y = contactWithObject.Y()

			p.isMoving = false

			otherTag := collision.Objects[0].Tags()[0]

			if otherTag == "target" {
				logging.Debug("Level won!")
				GameInstance.GoToNextLevel()
			} else if otherTag == "mob" {
				logging.Debug("Ya dead!")
			}
		}

		// now, update player's position
		p.obj.X += vel_x
		p.obj.Y += vel_y
		p.obj.Update()
	}
}

func (p *Player) Draw(screen *ebiten.Image) {
	geo := ebiten.GeoM{}
	geo.Translate(p.obj.X, p.obj.Y)
	ops := ebiten.DrawImageOptions{
		GeoM: geo,
	}
	screen.DrawImage(p.sprite, &ops)
}
