package main

import (
	_ "image/png"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/solarlune/ldtkgo"
	"github.com/solarlune/resolv"
	"github.com/tupini07/moto-tomo/controller"
	"github.com/tupini07/moto-tomo/gmath/physics"
	"github.com/tupini07/moto-tomo/gmath/vector"
	"github.com/tupini07/moto-tomo/logging"
)

type Player struct {
	sprite   *ebiten.Image
	obj      *resolv.Object
	isMoving bool
	moveVec  vector.Vector2

	standingOnSpike *Spike
}

func NewPlayer(space *resolv.Space, entity *ldtkgo.Entity) *Player {
	player := Player{
		isMoving: false,
		moveVec:  vector.Zero(),
		obj: resolv.NewObject(
			float64(entity.Position[0]),
			float64(entity.Position[1]),
			float64(entity.Width),
			float64(entity.Height),
			"player",
		),
	}

	space.Add(player.obj)

	for _, property := range entity.Properties {
		switch property.Identifier {
		case "Sprite":
			data := property.Value.(map[string]any)
			player.sprite = GameInstance.EbitenRenderer.getTile(
				int(data["x"].(float64)),
				int(data["y"].(float64)),
				int(data["w"].(float64)),
				int(data["h"].(float64)),
				0,
			)
		}
	}

	logging.Debugf("Created player: %+v", player)

	return &player
}

func (p *Player) Update(dt float64) {
	// speed := 130.0 / 2
	speed := 90.

	// check if we're standing on a spike that is active
	if p.standingOnSpike != nil {
		if p.standingOnSpike.obj.Overlaps(p.obj) {
			if p.standingOnSpike.isActive {
				GameInstance.PlayerDied(p.standingOnSpike.spriteActive)
			}
		} else {
			p.standingOnSpike = nil
		}
	}

	if !p.isMoving {
		moveVec := vector.Zero()

		if controller.IsActionPressed(controller.Up) {
			moveVec.Y = -1
		} else if controller.IsActionPressed(controller.Down) {
			moveVec.Y = 1
		} else if controller.IsActionPressed(controller.Left) {
			moveVec.X = -1
		} else if controller.IsActionPressed(controller.Right) {
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

			collidingWithSpike := physics.CollisionGetObjectWithTag(collision, "spike")

			// if we're colliding with a spike then we don't necessarily want to
			// stop
			if collidingWithSpike != nil {
				var otherSpike *Spike
				for _, s := range GameInstance.Spikes {
					if s.obj == collidingWithSpike {
						otherSpike = s
						break
					}
				}

				if otherSpike == nil {
					panic("Could not find spike that we collided with")
				}

				// if the spike is inactive then we can move through it (and we
				// need to activate it). But if it is active then we need to
				// die
				p.standingOnSpike = otherSpike
				otherSpike.Activate()
			}

			collidingWithSolid := physics.CollisionGetObjectWithTag(collision, "solid_wall")
			collidingWithTarget := physics.CollisionGetObjectWithTag(collision, "target")
			collidingWithMob := physics.CollisionGetObjectWithTag(collision, "mob")

			// if we collided with multiple objects then we resolve by priority
			var prirityObject *resolv.Object
			if collidingWithSolid != nil {
				prirityObject = collidingWithSolid
			} else if collidingWithTarget != nil {
				prirityObject = collidingWithTarget
			} else if collidingWithMob != nil {
				prirityObject = collidingWithMob
			}

			if prirityObject != nil {
				contactVec := collision.ContactWithObject(prirityObject)
				vel_x = contactVec.X()
				vel_y = contactVec.Y()
				p.isMoving = false
			}

			if collidingWithTarget != nil {
				GameInstance.GoToNextLevel()
			}

			// if we're colliding with a mob AND we haven't won the level then stop
			if collidingWithMob != nil && collidingWithTarget == nil {
				var otherSprite *ebiten.Image
				for _, m := range GameInstance.Mobs {
					if m.obj == collidingWithMob {
						otherSprite = m.sprite
						break
					}
				}
				if otherSprite == nil {
					panic("Could not find mob that we collided with")
				}

				GameInstance.PlayerDied(otherSprite)
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
