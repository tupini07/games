package main

import "github.com/hajimehoshi/ebiten/v2"

func (g *Game) DrawPlayer(screen *ebiten.Image) {
	g.currentBlock.pos.x += 1
}
