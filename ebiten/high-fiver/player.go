package main

import (
	_ "image/png"
	"log"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/hajimehoshi/ebiten/v2/inpututil"
)

const playerMarginSide = 20
const playerMoveSpeed = 2

type Player struct {
	playerImg *ebiten.Image
	drawOps   *ebiten.DrawImageOptions
}

func NewPlayer() *Player {
	playerImg, _, err := ebitenutil.NewImageFromFile("assets/player.png")

	if err != nil {
		log.Fatalf("Could not load player image! %s", err)
	}

	iw, ih := playerImg.Size()

	geo := ebiten.GeoM{}
	geo.Scale(2, 2)
	geo.Translate(float64(ScreenWidth/2-iw/2), (ScreenHeight/3*2)-float64(ih))

	pl := &Player{
		playerImg: playerImg,
		drawOps: &ebiten.DrawImageOptions{
			GeoM: geo,
		},
	}

	addProcess(pl)

	return pl
}

func (p *Player) update(dt float64) {

	if inpututil.IsKeyJustPressed(ebiten.KeyLeft) {
		shootArrow(DIR_LEFT, ALTITUDE_HIGH)
	} else if inpututil.IsKeyJustPressed(ebiten.KeyRight) {
		shootArrow(DIR_RIGHT, ALTITUDE_LOW)
	}

	// if p.movingRight {
	// 	marginRight := ScreenWidth - (p.block.pos.x + p.block.shape.width)
	// 	if marginRight <= playerMarginSide {
	// 		p.movingRight = false
	// 		return
	// 	}

	// 	p.block.pos.x += playerMoveSpeed
	// } else {
	// 	marginLeft := p.block.pos.x
	// 	if marginLeft <= playerMarginSide {
	// 		p.movingRight = true
	// 		return
	// 	}

	// 	p.block.pos.x -= playerMoveSpeed
	// }

	// if inpututil.IsKeyJustPressed(ebiten.KeySpace) {

	// }
}

func (p *Player) draw(screen *ebiten.Image) {
	screen.DrawImage(p.playerImg, p.drawOps)
}
