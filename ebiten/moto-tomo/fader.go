package main

import (
	"image/color"

	"github.com/hajimehoshi/ebiten/v2"

	ebivec "github.com/hajimehoshi/ebiten/v2/vector"
)

type OverlayFader struct {
	callback        func()
	overlayAlpha    uint8
	overlayDirction int
}

func NewOverlayFader(skipFadeOut bool, doneCallback func()) *OverlayFader {
	// suppse we need to fade out
	ovelayAlpha := 0
	overlayDirection := 1

	if skipFadeOut {
		ovelayAlpha = 255
		overlayDirection = -1
	}

	return &OverlayFader{
		callback:        doneCallback,
		overlayAlpha:    uint8(ovelayAlpha),
		overlayDirction: overlayDirection,
	}
}

func (f *OverlayFader) Update() bool {
	var alphaSpeed uint8 = 5

	// first we fade in if necessary
	if f.overlayDirction > 0 {
		if f.overlayAlpha < 255 {
			f.overlayAlpha += alphaSpeed
		}
	}

	// once we're completely "faded" invoke the callback and revert
	if f.overlayAlpha >= 255 {
		f.callback()
		f.overlayDirction = -1
	}

	if f.overlayDirction < 0 {
		if f.overlayAlpha > 0 {
			f.overlayAlpha -= alphaSpeed
		} else {
			f.overlayDirction = 0
			return true
		}
	}

	return false
}

func (f *OverlayFader) Draw(screen *ebiten.Image) {
	if f.overlayDirction != 0 {
		ebivec.DrawFilledRect(screen,
			0, 0,
			float32(screen.Bounds().Dx()),
			float32(screen.Bounds().Dy()),
			color.RGBA{0, 0, 0, f.overlayAlpha},
			false,
		)
	}
}
