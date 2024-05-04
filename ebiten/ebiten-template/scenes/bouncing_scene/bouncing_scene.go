package bouncing_scene

import (
	"github.com/hajimehoshi/ebiten/v2"
	"golang.org/x/image/colornames"
)

type BouncingScene struct {
}

func (intro_scene *BouncingScene) Init() {
}

func (intro_scene *BouncingScene) DeInit() {
}

func (intro_scene *BouncingScene) Update() {
}

func (intro_scene *BouncingScene) Draw(screen *ebiten.Image) {
	screen.Fill(colornames.Red)
}
