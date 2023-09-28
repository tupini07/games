package main

import (
	"image/color"
	"time"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/solarlune/gocoro"

	"github.com/hajimehoshi/ebiten/v2/text"
	ebivec "github.com/hajimehoshi/ebiten/v2/vector"
)

type OverlayFader struct {
	overlayAlpha uint8
	banner       *ebiten.Image
	textToDraw   string
}

func NewOverlayFader() *OverlayFader {
	return &OverlayFader{
		overlayAlpha: 0,
		textToDraw:   "",
	}
}

func overlayCoroutine(exe *gocoro.Execution) {
	f := GameInstance.overlayFader
	skipFadeOut := exe.Args[0].(bool)
	doneCallback := exe.Args[1].(func())

	if f.banner != nil {
		f.banner = ebiten.NewImageFromImage(f.banner)

		// replace all `RGBA{31, 14, 28, 255}` with `RGBA{0, 0, 0, 255}`
		// this is a hack to make the banner background transparent
		toReplace := color.RGBA{31, 14, 28, 255}
		replaceWith := color.RGBA{0, 0, 0, 255}
		for x := 0; x < f.banner.Bounds().Dx(); x++ {
			for y := 0; y < f.banner.Bounds().Dy(); y++ {
				if f.banner.At(x, y) == toReplace {
					f.banner.Set(x, y, replaceWith)
				}
			}
		}
	}

	// suppse we need to fade out
	f.overlayAlpha = 0

	if skipFadeOut {
		f.overlayAlpha = 255
	}

	// first we fade in if necessary
	for f.overlayAlpha < 255 {
		f.overlayAlpha += 5
		exe.Yield()
	}

	// once we're completely "faded" invoke the callback and revert
	doneCallback()

	// if there is a banner then yied for bit more to let the player apprciate
	// it
	if f.banner != nil {
		exe.YieldTime(2 * time.Second)
	}

	for f.overlayAlpha > 0 {
		f.overlayAlpha -= 5
		exe.Yield()
	}
}

func (f *OverlayFader) Draw(screen *ebiten.Image) {
	overlayImage := ebiten.NewImage(screen.Bounds().Dx(), screen.Bounds().Dy())

	ebivec.DrawFilledRect(overlayImage,
		0, 0,
		float32(screen.Bounds().Dx()),
		float32(screen.Bounds().Dy()),
		color.Black,
		false,
	)

	if f.banner != nil {
		// screen.Fill(color.RGBA{31, 14, 28, 255})
		ops := &ebiten.DrawImageOptions{}
		ops.GeoM.Scale(4, 4)

		overlayImage.DrawImage(f.banner, ops)
	}

	if f.textToDraw != "" {
		text.Draw(overlayImage, f.textToDraw, smallFontFace, 10, 10, color.White)
	}

	ops := &ebiten.DrawImageOptions{}
	ops.ColorScale.ScaleAlpha(float32(f.overlayAlpha) / 255.)
	screen.DrawImage(overlayImage, ops)
}
