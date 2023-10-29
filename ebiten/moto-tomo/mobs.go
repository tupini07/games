package main

import (
	"github.com/hajimehoshi/ebiten/v2"
	"github.com/solarlune/ldtkgo"
	"github.com/solarlune/resolv"
	"github.com/tupini07/moto-tomo/gmath/vector"
	"github.com/tupini07/moto-tomo/logging"
)

type Mob struct {
	sprite   *ebiten.Image
	obj      *resolv.Object
	isMoving bool
	moveVec  vector.Vector2

	walkPaths []vector.Vector2
	walkSpeed float64
	pauseTime float64

	pauseTimer float64
}

func NewMob(space *resolv.Space, entity *ldtkgo.Entity) *Mob {
	mob := Mob{
		obj: resolv.NewObject(
			float64(entity.Position[0]),
			float64(entity.Position[1]),
			float64(entity.Width),
			float64(entity.Height),
			"mob",
		),
	}

	space.Add(mob.obj)

	for _, property := range entity.Properties {
		switch property.Identifier {
		case "Sprite":
			data := property.Value.(map[string]any)
			mob.sprite = GameInstance.EbitenRenderer.getTile(
				int(data["x"].(float64)),
				int(data["y"].(float64)),
				int(data["w"].(float64)),
				int(data["h"].(float64)),
				0,
			)
		case "WalkSpeed":
			data := property.Value.(float64)
			mob.walkSpeed = data
		case "PauseTime":
			data := property.Value.(float64)
			mob.pauseTime = data
		case "WalkPath":
			data := property.Value.([]interface{})

			// +1 to account for the starting position
			mob.walkPaths = make([]vector.Vector2, len(data)+1)

			for i, path := range data {
				pathData := path.(map[string]any)
				mob.walkPaths[i] = vector.NewVector2(
					pathData["cx"].(float64)*WorldCellSize,
					pathData["cy"].(float64)*WorldCellSize,
				)
			}

			// add the starting position
			mob.walkPaths[len(data)] = vector.NewVector2(
				float64(entity.Position[0]),
				float64(entity.Position[1]),
			)
		default:
			logging.Warnf("NewMob: Unknown mob property: %s", property.Identifier)
		}
	}

	logging.Debugf("Created mob: %+v", mob)

	return &mob
}

func (m *Mob) Update(dt float64) {
	if m.pauseTimer > 0 {
		m.pauseTimer -= dt
		return
	}

	// if current position is not the same as the next position (head of the
	// queue), move towards it
	if m.obj.X != m.walkPaths[0].X || m.obj.Y != m.walkPaths[0].Y {
		m.isMoving = true
		m.moveVec = m.walkPaths[0].Subtract(vector.NewVector2(m.obj.X, m.obj.Y)).Normalize()
	}

	if m.isMoving {
		vel_x := m.moveVec.X * m.walkSpeed * dt
		vel_y := m.moveVec.Y * m.walkSpeed * dt

		// it could be that the mob collides with the player
		if collision := m.obj.Check(vel_x, vel_y, "player"); collision != nil {
			contactVec := collision.ContactWithObject(collision.Objects[0])
			vel_x = contactVec.X()
			vel_y = contactVec.Y()

			GameInstance.PlayerDied(m.sprite)
		}

		m.obj.X += vel_x
		m.obj.Y += vel_y
		m.obj.Update()
	}

	// if we're at the next position, rotate the queue
	if m.moveVec.X > 0 && m.obj.X >= m.walkPaths[0].X ||
		m.moveVec.X < 0 && m.obj.X <= m.walkPaths[0].X ||
		m.moveVec.Y > 0 && m.obj.Y >= m.walkPaths[0].Y ||
		m.moveVec.Y < 0 && m.obj.Y <= m.walkPaths[0].Y {

		m.obj.X = m.walkPaths[0].X
		m.obj.Y = m.walkPaths[0].Y

		m.walkPaths = append(m.walkPaths[1:], m.walkPaths[0])

		m.isMoving = false
		m.pauseTimer = m.pauseTime
	}

}

func (m *Mob) Draw(screen *ebiten.Image) {
	geo := ebiten.GeoM{}
	geo.Translate(m.obj.X, m.obj.Y)
	ops := ebiten.DrawImageOptions{
		GeoM: geo,
	}
	screen.DrawImage(m.sprite, &ops)

}
