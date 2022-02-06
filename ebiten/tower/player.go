package main

import "github.com/hajimehoshi/ebiten/v2"

const playerMarginSide = 20
const playerMoveSpeed = 2

type Player struct {
	block       *StackBlock
	movingRight bool
}

func (p *Player) UpdatePlayer() {

	if p.movingRight {
		marginRight := ScreenWidth - (p.block.pos.x + p.block.shape.width)
		if marginRight <= playerMarginSide {
			p.movingRight = false
			return
		}

		p.block.pos.x += playerMoveSpeed
	} else {
		marginLeft := p.block.pos.x
		if marginLeft <= playerMarginSide {
			p.movingRight = true
			return
		}

		p.block.pos.x -= playerMoveSpeed
	}
}

func (p *Player) DrawPlayer(screen *ebiten.Image) {
	p.block.DrawBlock(screen)
}
