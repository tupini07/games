package scenes

import (
	"github.com/hajimehoshi/ebiten/v2"
)

type Scene interface {
	Init()
	DeInit()
	Update()
	Draw(screen *ebiten.Image)
}

var currentScene Scene = nil

func GetCurrent() Scene {
	return currentScene
}

func SetCurrent(s Scene) {
	if currentScene != nil {
		currentScene.DeInit()
	}

	s.Init()
	currentScene = s
}
