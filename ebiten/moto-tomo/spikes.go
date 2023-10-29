package main

import (
	"github.com/hajimehoshi/ebiten/v2"
	"github.com/solarlune/ldtkgo"
	"github.com/solarlune/resolv"
	"github.com/tupini07/moto-tomo/logging"
)

type Spike struct {
	spriteInactive *ebiten.Image
	spriteActive   *ebiten.Image

	isActivating bool
	isActive     bool

	activeCountdown  float64
	timeToActivate   float64
	timeToDeactivate float64

	obj *resolv.Object
}

func NewSpike(space *resolv.Space, entity *ldtkgo.Entity) *Spike {
	spike := Spike{
		obj: resolv.NewObject(
			float64(entity.Position[0]),
			float64(entity.Position[1]),
			float64(entity.Width),
			float64(entity.Height),
			"spike",
		),
	}

	space.Add(spike.obj)

	for _, property := range entity.Properties {
		switch property.Identifier {
		case "ActiveSprite":
			data := property.Value.(map[string]any)
			spike.spriteActive = GameInstance.EbitenRenderer.getTile(
				int(data["x"].(float64)),
				int(data["y"].(float64)),
				int(data["w"].(float64)),
				int(data["h"].(float64)),
				0,
			)
		case "InactiveSprite":
			data := property.Value.(map[string]any)
			spike.spriteInactive = GameInstance.EbitenRenderer.getTile(
				int(data["x"].(float64)),
				int(data["y"].(float64)),
				int(data["w"].(float64)),
				int(data["h"].(float64)),
				0,
			)
		case "TimeToActivate":
			data := property.Value.(float64)
			spike.timeToActivate = data
		case "TimeToDeactivate":
			data := property.Value.(float64)
			spike.timeToDeactivate = data
		default:
			logging.Warnf("NewSpike: Unknown property %s", property.Identifier)
		}
	}

	logging.Debugf("Created spike at %+v", spike)

	return &spike
}

func (s *Spike) Activate() {
	if !s.isActivating && !s.isActive {
		s.isActivating = true
		s.activeCountdown = s.timeToActivate
	}
}

func (s *Spike) Update(dt float64) {
	if s.isActivating {
		s.activeCountdown -= dt
		if s.activeCountdown <= 0. {
			s.isActive = true
			s.isActivating = false
			s.activeCountdown = s.timeToDeactivate
		}
	} else if s.isActive {
		s.activeCountdown -= dt
		if s.activeCountdown <= 0 {
			s.isActive = false
		}
	}
}

func (s *Spike) Draw(screen *ebiten.Image) {
	geo := ebiten.GeoM{}
	geo.Translate(s.obj.X, s.obj.Y)
	ops := ebiten.DrawImageOptions{
		GeoM: geo,
	}

	sprite := s.spriteInactive
	if s.isActive {
		sprite = s.spriteActive
	}

	screen.DrawImage(sprite, &ops)

	DrawObjCollider(screen, s.obj)
}
