package main

import (
	"fmt"
	"log"
	"math/rand"
	"os"
	"time"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/hajimehoshi/ebiten/v2/inpututil"
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
	camera    Camera
	world     *ebiten.Image
	allBlocks []*StackBlock
	player    Player
}

func (g *Game) Update() error {
	if g.player.block == nil {
		newBlock := MakeRandomBlock()
		newBlock.pos.y = ScreenHeight / 7

		g.player.block = &newBlock
	}

	if inpututil.IsKeyJustPressed(ebiten.KeyQ) {
		os.Exit(0)
	}

	g.player.UpdatePlayer()

	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	g.world.Clear()

	cb := g.player.block
	ebitenutil.DebugPrint(screen, fmt.Sprintf("%#v", cb))

	const baseWidth = 100
	const baseHeight = 40
	ebitenutil.DrawRect(g.world,
		ScreenWidth/2-baseWidth/2,
		ScreenHeight-baseHeight,
		baseWidth,
		baseHeight,
		colornames.Cornflowerblue)

	g.player.DrawPlayer(g.world)

	for _, block := range g.allBlocks {
		block.DrawBlock(g.world)
	}

	g.camera.Render(g.world, screen)
}

func (g *Game) Layout(outsideWidth, outsideHeight int) (screenWidth, screenHeight int) {
	return 320, 240
}

func main() {
	rand.Seed(time.Now().UnixNano())

	ebiten.SetWindowSize(640, 480)
	ebiten.SetWindowTitle("Hello, World!")

	game := &Game{
		allBlocks: make([]*StackBlock, 0),
		camera:    Camera{ViewPort: f64.Vec2{ScreenWidth, ScreenWidth}},
		world:     ebiten.NewImage(worldWidth, worldHeight),
		player: Player{
			movingRight: true,
		},
	}

	if err := ebiten.RunGame(game); err != nil {
		log.Fatal(err)
	}
}
