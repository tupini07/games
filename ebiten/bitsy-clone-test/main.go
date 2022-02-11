package main

import (
	"log"
	"math/rand"
	"os"
	"time"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/hajimehoshi/ebiten/v2/inpututil"
	"github.com/solarlune/ldtkgo/ebitenrenderer"
	"golang.org/x/exp/shiny/materialdesign/colornames"
)

const (
	ScreenWidth  = 256
	ScreenHeight = 256
	windowScale  = 3

	worldWidth  = 10_000
	worldHeight = 10_000
)

var renderer *ebitenrenderer.EbitenRenderer

// var ldtkProject *ldtkgo.Project

type Game struct {
	world *ebiten.Image
}

func (g *Game) Update() error {
	if inpututil.IsKeyJustPressed(ebiten.KeyQ) {
		os.Exit(0)
	}

	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	screen.Clear()

	// lvl := ldtkProject.Levels[0]
	// renderer.Render(lvl)

	for _, layer := range renderer.RenderedLayers {
		screen.DrawImage(layer.Image, &ebiten.DrawImageOptions{})
	}

	size := 40.0
	mx, my := ebiten.CursorPosition()
	ebitenutil.DrawRect(screen, float64(mx)-size/2, float64(my)-size/2, size, size, colornames.AmberA400)

	imgage, _, _ := ebitenutil.NewImageFromFile("assets/tiles.png")
	screen.DrawImage(imgage, &ebiten.DrawImageOptions{})

	ebitenutil.DrawLine(screen, 0, float64(my), ScreenWidth, float64(my), colornames.Green100)
	ebitenutil.DrawLine(screen, float64(mx), 0, float64(mx), ScreenWidth, colornames.Purple100)
}

func (g *Game) Layout(outsideWidth, outsideHeight int) (int, int) {
	return ScreenWidth, ScreenHeight
}

func main() {
	// ldtk_Project, err := ldtkgo.Open("assets/levels.ldtk")
	// if err != nil {
	// 	panic(err)
	// }

	// ldtkProject = ldtk_Project

	renderer = ebitenrenderer.NewEbitenRenderer(ebitenrenderer.NewDiskLoader("assets"))

	rand.Seed(time.Now().UnixNano())

	ebiten.SetWindowSize(ScreenWidth*windowScale, ScreenWidth*windowScale)
	ebiten.SetWindowTitle("Hello, World!")

	game := &Game{
		world: ebiten.NewImage(worldWidth, worldHeight),
	}

	if err := ebiten.RunGame(game); err != nil {
		log.Fatal(err)
	}
}
