package main

import (
	_ "embed"
	"fmt"
	"math"
	"runtime"

	"image/color"
	"syscall"

	"github.com/hajimehoshi/ebiten/v2/inpututil"
	"github.com/hajimehoshi/ebiten/v2/text"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/solarlune/gocoro"
	"github.com/solarlune/ldtkgo"
	"github.com/solarlune/resolv"

	"github.com/tupini07/moto-tomo/constants"
	"github.com/tupini07/moto-tomo/controller"
	"github.com/tupini07/moto-tomo/gmath"
	"github.com/tupini07/moto-tomo/logging"
	"github.com/tupini07/moto-tomo/memory"
)

//go:embed assets/maps/world.ldtk
var ldtkMapBytes []byte

const WorldCellSize = 10
const ViewportWidth = 130
const ViewportHeight = 130

type Game struct {
	currentLevel int
	gameWon      bool
	overlayFader *OverlayFader

	worldImage     *ebiten.Image
	LDTKProject    *ldtkgo.Project
	EbitenRenderer *EbitenRenderer

	Coroutine gocoro.Coroutine
	Space     *resolv.Space

	Player *Player
	Mobs   []*Mob
}

var GameInstance *Game = nil

func main() {
	ebiten.SetWindowSize(ViewportWidth, ViewportHeight)
	ebiten.SetWindowTitle("moto-tomo")
	ebiten.SetWindowResizingMode(ebiten.WindowResizingModeEnabled)
	ebiten.SetWindowSize(ViewportWidth*4.5, ViewportHeight*4)
	ebiten.SetVsyncEnabled(true)

	loadFonts()
	registerKeybindings()

	GameInstance = &Game{
		currentLevel: -1,
		gameWon:      false,
		overlayFader: NewOverlayFader(),
		worldImage:   ebiten.NewImage(ViewportWidth, ViewportHeight),
		Coroutine:    gocoro.NewCoroutine(),
		Space:        resolv.NewSpace(ViewportWidth, ViewportHeight, 5, 5),
		Mobs:         make([]*Mob, 0),
	}

	var err error
	// GameInstance.LDTKProject, err = ldtkgo.Open("assets/maps/world.ldtk")
	GameInstance.LDTKProject, err = ldtkgo.Read(ldtkMapBytes)
	if err != nil {
		panic(err)
	}

	GameInstance.EbitenRenderer = NewEbitenRenderer(NewDiskLoader("assets/maps"))

	currentLevel, exists := memory.GetInt("currentLevel")
	if exists {
		GameInstance.currentLevel = currentLevel - 1
	}

	GameInstance.GoToNextLevel()

	if err := ebiten.RunGame(GameInstance); err != nil {
		logging.Error(err)
	}
}

func registerKeybindings() {
	controller.Map(controller.Up, ebiten.KeyW, ebiten.KeyUp)
	controller.Map(controller.Down, ebiten.KeyS, ebiten.KeyDown)
	controller.Map(controller.Left, ebiten.KeyA, ebiten.KeyLeft)
	controller.Map(controller.Right, ebiten.KeyD, ebiten.KeyRight)
}

func (g *Game) initLevel() {
	logging.Debugf("Initializing level: %d", g.currentLevel)

	var currentLevel = g.LDTKProject.Levels[g.currentLevel]
	g.EbitenRenderer.Render(currentLevel)

	g.worldImage = ebiten.NewImage(
		currentLevel.Width,
		currentLevel.Height,
	)

	g.Space = resolv.NewSpace(
		currentLevel.Width,
		currentLevel.Height,
		1, 1,
	)

	g.Mobs = make([]*Mob, 0)

	// add solid tiles to space
	entitiesLayer := currentLevel.LayerByIdentifier("Entities")
	for _, entity := range entitiesLayer.Entities {
		pos_x, pos_y := float64(entity.Position[0]), float64(entity.Position[1])
		width, height := float64(entity.Width), float64(entity.Height)

		if entity.Identifier == "Player" {
			player := NewPlayer(g.Space, entity)
			g.Player = player
			logging.Debugf("Created player at (%f, %f)", pos_x, pos_y)

		} else if entity.Identifier == "Solid" {
			g.Space.Add(resolv.NewObject(pos_x, pos_y, width, height, "solid_wall"))
			logging.Debugf("Created solid wall at (%f, %f) with width %f and height %f", pos_x, pos_y, width, height)

		} else if entity.Identifier == "Target" {
			g.Space.Add(resolv.NewObject(pos_x, pos_y, width, height, "target"))
			logging.Debugf("Created target at (%f, %f) with width %f and height %f", pos_x, pos_y, width, height)

		} else if entity.Identifier == "Mob" {
			g.Mobs = append(g.Mobs, NewMob(g.Space, entity))
		}
	}
}

func (g *Game) initGameWon() {
	logging.Debug("Initializing game won scene")

	g.gameWon = true
	g.Mobs = make([]*Mob, 0)
}

func showOverlay(skipOverlayFadeOut bool, callback func(), spriteOfKiller *ebiten.Image, textToDraw string) {
	GameInstance.overlayFader.banner = spriteOfKiller
	GameInstance.overlayFader.textToDraw = textToDraw

	GameInstance.Coroutine.Run(overlayCoroutine, skipOverlayFadeOut, callback)
}

func (g *Game) PlayerDied(spriteOfKiller *ebiten.Image) {
	showOverlay(false, g.initLevel, spriteOfKiller, "You died!")
}

func (g *Game) GoToNextLevel() {
	g.currentLevel += 1
	memory.Save("currentLevel", g.currentLevel)

	skipOverlayFadeOut := g.currentLevel == 0

	callbackFun := g.initLevel
	isThereNextLevel := len(g.LDTKProject.Levels) > g.currentLevel
	if !isThereNextLevel {
		callbackFun = g.initGameWon
	}

	lvlStr := fmt.Sprintf("Level: %d", g.currentLevel+1)
	showOverlay(skipOverlayFadeOut, callbackFun, nil, lvlStr)
}

func (g *Game) Layout(outsideWidth int, outsideHeight int) (screenWidth int, screenHeight int) {
	return ViewportWidth, ViewportHeight
}

func (g *Game) Update() error {
	// https://github.com/hajimehoshi/ebiten/issues/335
	const dt float64 = 1. / 60.

	if constants.Debug {
		// go to next level
		if !g.Coroutine.Running() && ebiten.IsKeyPressed(ebiten.KeyAltLeft) {
			logging.Debug("Changing level")

			if inpututil.IsKeyJustPressed(ebiten.KeyN) {
				logging.Debug("Going to next level")

				g.gameWon = false
				g.currentLevel = gmath.Clamp(g.currentLevel, 0, len(g.LDTKProject.Levels)-1)
				g.GoToNextLevel()
			}

			// go to previous level
			if inpututil.IsKeyJustPressed(ebiten.KeyP) {
				logging.Debug("Going to prvious level")

				g.gameWon = false
				g.currentLevel = gmath.Clamp(g.currentLevel-2, -1, len(g.LDTKProject.Levels)-1)
				g.GoToNextLevel()
			}
		}

		if runtime.GOARCH != "wasm" && ebiten.IsKeyPressed(ebiten.KeyEscape) {
			syscall.Exit(0)
		}
	}

	if g.gameWon {
		g.Coroutine.Update()
		return nil
	}

	for _, mob := range g.Mobs {
		mob.Update(dt)
	}

	// If coroutine is running then it means we don't want to update the player
	if g.Coroutine.Running() {
		g.Coroutine.Update()
	} else {
		g.Player.Update(dt)
	}

	return nil
}

func (g *Game) Draw(screen *ebiten.Image) {

	if g.gameWon {
		screen.Fill(color.RGBA{31, 14, 28, 255})
		text.Draw(screen, "game won!", bigFontFace, 10, 40, color.White)
		text.Draw(screen, "Now what?", smallFontFace, 10, 50, color.White)

		return
	}

	g.worldImage.Fill(color.RGBA{31, 14, 28, 255})

	for _, layer := range g.EbitenRenderer.RenderedLayers {
		g.worldImage.DrawImage(layer.Image, &ebiten.DrawImageOptions{})
	}

	// this works as a pseudo camera
	geo := ebiten.GeoM{}

	if g.Player != nil {
		g.Player.Draw(g.worldImage)

		tx := (g.Player.obj.X + g.Player.obj.W/2) - ViewportWidth/2
		tx = gmath.Clamp(tx, 0, float64(g.worldImage.Bounds().Dx())-ViewportWidth)

		ty := (g.Player.obj.Y + g.Player.obj.H/2) - ViewportHeight/2
		ty = gmath.Clamp(ty, 0, float64(g.worldImage.Bounds().Dy())-ViewportHeight)

		tx = math.Round(tx)
		ty = math.Round(ty)

		geo.Translate(-tx, -ty)
	}

	for _, mob := range g.Mobs {
		mob.Draw(g.worldImage)
	}

	ops := &ebiten.DrawImageOptions{
		GeoM: geo,
	}
	screen.DrawImage(g.worldImage, ops)

	if g.overlayFader != nil {
		g.overlayFader.Draw(screen)
	}

}
