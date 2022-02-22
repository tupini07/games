package main

import (
	"bufio"
	_ "embed"
	"io/ioutil"
	"log"
	"math/rand"
	"os"
	"time"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/hajimehoshi/ebiten/v2/inpututil"
)

const (
	ScreenWidth  = 400
	ScreenHeight = ScreenWidth * 1.7
)

type Game struct {
	player *Player
	txt    string
}

var lastUpdateTime = time.Now()

func (g *Game) Update() error {
	dt := time.Since(lastUpdateTime).Seconds()
	lastUpdateTime = time.Now()

	if inpututil.IsKeyJustPressed(ebiten.KeyQ) {
		os.Exit(0)
	}

	for _, proc := range allProcesses {
		proc.update(dt)
	}

	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	screen.Clear()

	for _, proc := range allProcesses {
		proc.draw(screen)
	}

	ebitenutil.DebugPrint(screen, g.txt)
}

func (g *Game) Layout(outsideWidth, outsideHeight int) (screenWidth, screenHeight int) {
	return ScreenWidth, ScreenHeight
}

func main() {
	rand.Seed(time.Now().UnixNano())

	ebiten.SetWindowSize(ScreenWidth, ScreenHeight)
	ebiten.SetWindowTitle("High Five Simulator")

	file, err := ebitenutil.OpenFile("assets/a-test-file.json")
	if err != nil {
		log.Fatal(err)
	}

	defer file.Close()

	reader := bufio.NewReader(file)
	data, err := ioutil.ReadAll(reader)
	if err != nil {
		log.Fatal(err)
	}

	game := &Game{
		player: NewPlayer(),
		txt:    string(data),
	}

	if err := ebiten.RunGame(game); err != nil {
		log.Fatal(err)
	}
}
