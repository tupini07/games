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
	overlayAlpha    uint8
	displayingStory bool
	banner          *ebiten.Image
	mainText        string
	subText         string
	storyFader      *StoryFader
}

func NewOverlayFader() *OverlayFader {
	return &OverlayFader{
		overlayAlpha:    0,
		displayingStory: false,
		mainText:        "",
		subText:         "",
		storyFader:      nil,
	}
}

func showOverlay(
	skipOverlayFadeOut bool,
	callback func() bool,
	spriteOfKiller *ebiten.Image,
	mainText, subText string,
	storyFrames ...string,
) {
	GameInstance.overlayFader.banner = spriteOfKiller
	GameInstance.overlayFader.mainText = mainText
	GameInstance.overlayFader.subText = subText

	if len(storyFrames) > 0 {
		GameInstance.overlayFader.storyFader = NewStoryFader(storyFrames)
	}

	GameInstance.Coroutine.Run(overlayCoroutine, skipOverlayFadeOut, callback)
}

func overlayCoroutine(exe *gocoro.Execution) {
	f := GameInstance.overlayFader
	skipFadeOut := exe.Args[0].(bool)
	doneCallback := exe.Args[1].(func() bool)

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

	// once we're completely "faded" invoke the callback and revert. This will
	// yield for as long as the callback returns `false`
	for !doneCallback() {
		exe.Yield()
	}

	// story frames
	for f.storyFader != nil && f.storyFader.coroutine.Running() {
		f.displayingStory = true
		f.storyFader.coroutine.Update()
		exe.Yield()
	}

	exe.YieldTime(500 * time.Millisecond)

	// if there is a banner then yied for bit more to let the player apprciate
	// it
	if f.banner != nil {
		exe.YieldTime(2 * time.Second)
	}

	for f.overlayAlpha > 0 {
		f.overlayAlpha -= 5
		exe.Yield()
	}

	f.storyFader = nil
	GameInstance.levelStartTime = time.Now()
	f.displayingStory = false
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
		ops := &ebiten.DrawImageOptions{}

		// image should be centered on vertical
		ops.GeoM.Translate(
			-float64(f.banner.Bounds().Dx()/2),
			-float64(f.banner.Bounds().Dy()/2),
		)

		// scale on center
		ops.GeoM.Scale(4, 4)

		ops.GeoM.Translate(
			float64(screen.Bounds().Dx()/2),
			float64(screen.Bounds().Dy()/4),
		)

		// ops.GeoM.Translate(
		// 	float64(f.banner.Bounds().Dx()/2),
		// 	float64(f.banner.Bounds().Dy()/2),
		// )

		overlayImage.DrawImage(f.banner, ops)
	}

	if f.displayingStory {
		f.storyFader.Draw(overlayImage)
	} else {
		if f.mainText != "" {
			text.Draw(overlayImage, f.mainText, bigFontFace, 10, 80, color.White)
		}

		if f.subText != "" {
			text.Draw(overlayImage, f.subText, smallFontFace, 10, 90, color.White)
		}
	}

	ops := &ebiten.DrawImageOptions{}
	ops.ColorScale.ScaleAlpha(float32(f.overlayAlpha) / 255.)
	screen.DrawImage(overlayImage, ops)
}
