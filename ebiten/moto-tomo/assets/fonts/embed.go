package fonts

import (
	_ "embed"
)

var (
	//go:embed pixel-emulator/PixelEmulator-xq08.ttf
	PixelEmulator_xq08_ttf []byte

	//go:embed  pico-8/pico-8.ttf
	Pico8_ttf []byte
)
