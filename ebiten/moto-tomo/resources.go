package main

import (
	"log"

	"github.com/tupini07/moto-tomo/assets/fonts"
	"golang.org/x/image/font"
	"golang.org/x/image/font/opentype"
)

var bigFontFace font.Face
var smallFontFace font.Face

func loadFonts() {
	var err error

	// Load big font face
	tt, err := opentype.Parse(fonts.PixelEmulator_xq08_ttf)
	if err != nil {
		log.Fatal(err)
	}

	const dpi = 72
	bigFontFace, err = opentype.NewFace(tt, &opentype.FaceOptions{
		Size:    10,
		DPI:     dpi,
		Hinting: font.HintingFull,
	})
	if err != nil {
		log.Fatal(err)
	}

	// Load small font face
	tt, err = opentype.Parse(fonts.Pico8_ttf)
	if err != nil {
		log.Fatal(err)
	}

	smallFontFace, err = opentype.NewFace(tt, &opentype.FaceOptions{
		Size:    6,
		DPI:     dpi,
		Hinting: font.HintingFull,
	})
	if err != nil {
		log.Fatal(err)
	}
}
