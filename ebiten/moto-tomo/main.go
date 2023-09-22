package main

import (
	"image/color"
	"log"
	"syscall"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/solarlune/ldtkgo"
	"github.com/solarlune/resolv"
)

type Game struct {
	currentLevel int
	overlayFader *OverlayFader

	LDTKProject    *ldtkgo.Project
	EbitenRenderer *EbitenRenderer

	Space *resolv.Space

	Player *Player
}

func main() {
	ebiten.SetWindowSize(130, 130)
	ebiten.SetWindowTitle("moto-tomo")
	ebiten.SetWindowResizingMode(ebiten.WindowResizingModeEnabled)
	ebiten.SetWindowSize(130*4.5, 130*4)
	ebiten.SetVsyncEnabled(true)

	game := &Game{
		currentLevel: -1,
		Space:        resolv.NewSpace(130, 130, 5, 5),
	}

	var err error
	game.LDTKProject, err = ldtkgo.Open("assets/maps/world.ldtk")
	if err != nil {
		panic(err)
	}

	game.EbitenRenderer = NewEbitenRenderer(NewDiskLoader("assets/maps"))

	game.GoToNextLevel()

	if err := ebiten.RunGame(game); err != nil {
		log.Fatal(err)
	}
}

func (g *Game) GoToNextLevel() {
	g.currentLevel += 1
	log.Printf("Starting level: %d", g.currentLevel)

	skipOverlayFadeOut := g.currentLevel == 0
	g.overlayFader = NewOverlayFader(skipOverlayFadeOut, func() {
		log.Println("Overlay done, inside callback")

		var currentLevel = g.LDTKProject.Levels[g.currentLevel]
		g.EbitenRenderer.Render(currentLevel)

		// add solid tiles to space
		entitiesLayer := currentLevel.LayerByIdentifier("Entities")
		for _, entity := range entitiesLayer.Entities {
			pos_x, pos_y := float64(entity.Position[0]), float64(entity.Position[1])
			width, height := float64(entity.Width), float64(entity.Height)

			if entity.Identifier == "Player" {
				player := NewPlayer(g.Space, pos_x, pos_y)
				g.Player = player
				log.Printf("Created player at (%f, %f)", pos_x, pos_y)

			} else if entity.Identifier == "Solid" {
				g.Space.Add(resolv.NewObject(pos_x, pos_y, width, height, "solid_wall"))
				log.Printf("Created solid wall at (%f, %f) with width %f and height %f", pos_x, pos_y, width, height)

			} else if entity.Identifier == "Target" {
				g.Space.Add(resolv.NewObject(pos_x, pos_y, width, height, "target"))
				log.Printf("Created target at (%f, %f) with width %f and height %f", pos_x, pos_y, width, height)
			}
		}
	})
}

func (g *Game) Layout(outsideWidth int, outsideHeight int) (screenWidth int, screenHeight int) {
	return 130, 130
}

func (g *Game) Update() error {
	if ebiten.IsKeyPressed(ebiten.KeyEscape) {
		syscall.Exit(0)
	}

	if g.overlayFader != nil {
		overlayDone := g.overlayFader.Update()
		if overlayDone {
			g.overlayFader = nil
		}

		// skip updating other stuff if the overlay is still doing its thing
		return nil
	}

	// https://github.com/hajimehoshi/ebiten/issues/335
	var dt float64 = 1. / 60.

	g.Player.update(dt)

	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	screen.Fill(color.RGBA{31, 14, 28, 255})

	for _, layer := range g.EbitenRenderer.RenderedLayers {
		screen.DrawImage(layer.Image, &ebiten.DrawImageOptions{})
	}

	if g.Player != nil {
		g.Player.draw(screen)
	}

	if g.overlayFader != nil {
		g.overlayFader.Draw(screen)
	}
}
