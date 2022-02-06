package main

import (
	"log"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"golang.org/x/image/colornames"
	"golang.org/x/image/math/f64"
)

const (
	ScreenWidth  = 320
	ScreenHeight = 240
)

const (
	worldWidth  = ScreenWidth
	worldHeight = 10_000
)

type Game struct {
	camera       Camera
	world        *ebiten.Image
	currentBlock *StackBlock
	allBlocks    []*StackBlock
}

func (g *Game) Update() error {
	if g.currentBlock == nil {
		newBlock := MakeRandomBlock()
		g.currentBlock = &newBlock
	}

	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	ebitenutil.DebugPrint(screen, "Hello, World!")

	const baseWidth = 100
	const baseHeight = 40
	ebitenutil.DrawRect(g.world,
		ScreenWidth/2-baseWidth/2,
		ScreenHeight-baseHeight,
		baseWidth,
		baseHeight,
		colornames.Cornflowerblue)

	g.DrawPlayer(g.world)

	g.camera.Render(g.world, screen)
}

func (g *Game) Layout(outsideWidth, outsideHeight int) (screenWidth, screenHeight int) {
	return 320, 240
}

func main() {
	ebiten.SetWindowSize(640, 480)
	ebiten.SetWindowTitle("Hello, World!")

	game := &Game{
		currentBlock: nil,
		allBlocks:    make([]*StackBlock, 0),
		camera:       Camera{ViewPort: f64.Vec2{ScreenWidth, ScreenWidth}},
		world:        ebiten.NewImage(worldWidth, worldHeight),
	}

	if err := ebiten.RunGame(game); err != nil {
		log.Fatal(err)
	}
}
