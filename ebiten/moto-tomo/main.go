package main

import (
	"image/color"
	"log"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/solarlune/ldtkgo"
	"github.com/solarlune/resolv"
)

type Game struct {
	Buffer *ebiten.Image

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
		Buffer: ebiten.NewImage(130, 130),
		Space:  resolv.NewSpace(130, 130, 10, 10),
	}

	var err error
	game.LDTKProject, err = ldtkgo.Open("assets/maps/world.ldtk")
	if err != nil {
		panic(err)
	}

	game.EbitenRenderer = NewEbitenRenderer(NewDiskLoader("assets/maps"))
	game.EbitenRenderer.Render(game.LDTKProject.Levels[0])

	player := NewPlayer(game.Space)
	game.Player = player

	if err := ebiten.RunGame(game); err != nil {
		log.Fatal(err)
	}
}

func (g *Game) Layout(outsideWidth int, outsideHeight int) (screenWidth int, screenHeight int) {
	return 130, 130
}

func (g *Game) Update() error {
	dt := 1.0 / ebiten.ActualTPS()

	g.Player.update(dt)
	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	g.Buffer.Fill(color.RGBA{31, 14, 28, 255})

	for _, layer := range g.EbitenRenderer.RenderedLayers {
		// TODO this is rendering outside, the reason is the scale below. It is
		// rendering the left and right walls between bounds, only the bottom
		// wall is rendered outside.
		g.Buffer.DrawImage(layer.Image, &ebiten.DrawImageOptions{})
	}

	g.Player.draw(g.Buffer)

	// scale buffer as a square so we fill the screen
	// scale := float64(g.Width) / float64(g.Buffer.Bounds().Dx())
	// scale := float64(g.Width) / float64(g.Buffer.Bounds().Dy())
	scale := 1.0

	geo := ebiten.GeoM{}
	geo.Scale(scale, scale)
	ops := ebiten.DrawImageOptions{
		GeoM: geo,
	}
	screen.DrawImage(g.Buffer, &ops)
}
