package main

import (
	"bufio"
	_ "embed"
	"errors"
	"io"
	"log"
	"math/rand"
	"os"
	"time"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/ebitenutil"
	"github.com/hajimehoshi/ebiten/v2/inpututil"
	"golang.org/x/image/colornames"
)

const (
	ScreenWidth  = 400
	ScreenHeight = ScreenWidth * 1.7
)

type Game struct {
	player *Player
	txt    string
}

func (g *Game) Update() error {
	if inpututil.IsKeyJustPressed(ebiten.KeyQ) {
		os.Exit(0)
	}

	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {
	// TODO we might be able to remove it
	screen.Clear()

	ebitenutil.DrawRect(screen,
		10,
		10,
		100,
		200,
		colornames.Cornflowerblue)

	g.player.DrawPlayer(screen)

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

	str, err := reader.ReadString(byte(0))
	if err != nil && !errors.Is(err, io.EOF) {
		log.Fatal(err)
	}

	game := &Game{
		player: NewPlayer(),
		txt:    str,
	}

	if err := ebiten.RunGame(game); err != nil {
		log.Fatal(err)
	}
}
