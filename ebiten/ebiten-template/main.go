package main

import (
	"log"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/tupini07/ebiten-template/scenes"
	"github.com/tupini07/ebiten-template/scenes/intro_scene"
)

type game struct {
}

func main() {
	ebiten.SetWindowSize(900, 800)
	ebiten.SetWindowTitle("Ebiten UI Hello World")
	ebiten.SetWindowResizingMode(ebiten.WindowResizingModeEnabled)
	ebiten.SetScreenClearedEveryFrame(false)
	ebiten.SetVsyncEnabled(true)

	scenes.SetCurrent(&intro_scene.IntroScene{})

	game := game{}

	err := ebiten.RunGame(&game)
	if err != nil {
		log.Print(err)
	}
}

func (g *game) Update() error {
	scenes.GetCurrent().Update()

	return nil
}

func (g *game) Draw(screen *ebiten.Image) {
	scenes.GetCurrent().Draw(screen)
}

func (g *game) Layout(outsideWidth int, outsideHeight int) (int, int) {
	return outsideWidth, outsideHeight
}
