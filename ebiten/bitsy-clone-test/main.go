package main

import (
	"log"
	"math/rand"
	"os"
	"time"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/inpututil"
	"github.com/solarlune/ldtkgo"
	"github.com/solarlune/ldtkgo/ebitenrenderer"
)

const (
	ScreenWidth  = 256
	ScreenHeight = 256
	windowScale  = 3

	worldWidth  = 10_000
	worldHeight = 10_000
)

var renderer *ebitenrenderer.EbitenRenderer
var ldtkProject *ldtkgo.Project

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

	lvl := ldtkProject.Levels[0]
	renderer.Render(lvl)

	for _, layer := range renderer.RenderedLayers {
		screen.DrawImage(layer.Image, &ebiten.DrawImageOptions{})
	}

}

func (g *Game) Layout(outsideWidth, outsideHeight int) (int, int) {
	return ScreenWidth, ScreenHeight
}

func main() {
	ldtk_Project, err := ldtkgo.Open("assets/levels.ldtk")
	if err != nil {
		panic(err)
	}

	ldtkProject = ldtk_Project

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
