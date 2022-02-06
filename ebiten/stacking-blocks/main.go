package main

import (
	"log"
	"math/rand"
	"os"
	"time"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/hajimehoshi/ebiten/v2/inpututil"
	"github.com/jakecoffman/cp"
	"golang.org/x/image/colornames"
	"golang.org/x/image/math/f64"
)

const (
	ScreenWidth  = 320
	ScreenHeight = 240
	worldWidth   = ScreenWidth
	worldHeight  = 10_000
)
const (
	baseWidth  = 100
	baseHeight = 40
	baseX      = ScreenWidth/2 - baseWidth/2
	baseY      = ScreenHeight - baseHeight
)

type Game struct {
	camera    Camera
	world     *ebiten.Image
	allBlocks []*StackBlock
	player    Player
	space     *cp.Space
}

func (g *Game) Update() error {
	g.space.Step(1.0 / float64(ebiten.MaxTPS()))

	if g.player.block == nil {
		newBlock := MakeRandomBlock(g.space)
		// newBlock.pos.y = ScreenHeight / 7

		g.player.block = &newBlock
	}

	if inpututil.IsKeyJustPressed(ebiten.KeyQ) {
		os.Exit(0)
	}

	g.player.UpdatePlayer(&g.allBlocks)

	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	g.world.Clear()

	// cb := g.player.block
	// ebitenutil.DebugPrint(screen, fmt.Sprintf("%#v", cb))

	const baseWidth = 100
	const baseHeight = 40
	ebitenutil.DrawRect(g.world,
		baseX,
		baseY,
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
		space:     cp.NewSpace(),
		player: Player{
			movingRight: true,
		},
	}

	// create body for base
	baseBody := game.space.AddBody(cp.NewBody(cp.INFINITY, cp.INFINITY))
	baseBody.SetPosition(cp.Vector{X: baseX, Y: baseY})
	baseBody.SetVelocity(0, 0)

	baseShape := game.space.AddShape(cp.NewBox(baseBody, baseWidth, baseHeight, 0))
	baseShape.SetElasticity(1)
	baseShape.SetFriction(cp.INFINITY)

	game.space.Iterations = 30
	game.space.SetGravity(cp.Vector{X: 0, Y: 100})
	game.space.SleepTimeThreshold = 0.5
	game.space.SetCollisionSlop(0.5)

	if err := ebiten.RunGame(game); err != nil {
		log.Fatal(err)
	}
}
