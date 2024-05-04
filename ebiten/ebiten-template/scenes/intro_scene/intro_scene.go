package intro_scene

import (
	"image/color"
	"log"

	"github.com/ebitenui/ebitenui"
	"github.com/ebitenui/ebitenui/image"
	"github.com/ebitenui/ebitenui/widget"
	"github.com/golang/freetype/truetype"
	"github.com/hajimehoshi/ebiten/v2"
	"github.com/tupini07/ebiten-template/scenes"
	"github.com/tupini07/ebiten-template/scenes/bouncing_scene"
	"golang.org/x/image/colornames"
	"golang.org/x/image/font"
	"golang.org/x/image/font/gofont/goregular"
)

type IntroScene struct {
	ui *ebitenui.UI
}

func (intro_scene *IntroScene) Init() {
	rootContainer := widget.NewContainer(
		// the container will use a plain color as its background
		widget.ContainerOpts.BackgroundImage(image.NewNineSliceColor(color.NRGBA{0x13, 0x1a, 0x22, 0xff})),
		widget.ContainerOpts.Layout(widget.NewRowLayout(
			//Which direction to layout children
			widget.RowLayoutOpts.Direction(widget.DirectionVertical),
			//Set how much padding before displaying content
			widget.RowLayoutOpts.Padding(widget.NewInsetsSimple(30)),
			//Set how far apart to space the children
			widget.RowLayoutOpts.Spacing(15),
		)),
	)

	rootContainer.AddChild(makeText("Potato"))

	rootContainer.AddChild(makeButton("Go to bouncing scene", func(args *widget.ButtonClickedEventArgs) {
		scenes.SetCurrent(&bouncing_scene.BouncingScene{})
	}))

	rootContainer.AddChild(makeButton("btn2", func(args *widget.ButtonClickedEventArgs) {

	}))

	ui := ebitenui.UI{
		Container: rootContainer,
	}

	intro_scene.ui = &ui
}

func (intro_scene *IntroScene) DeInit() {
}

func (intro_scene *IntroScene) Update() {
	intro_scene.ui.Update()
}

func (intro_scene *IntroScene) Draw(screen *ebiten.Image) {
	intro_scene.ui.Draw(screen)
}

func makeText(text string) *widget.Text {
	ttfFont, err := truetype.Parse(goregular.TTF)
	if err != nil {
		log.Fatal(err)
	}

	face := truetype.NewFace(ttfFont, &truetype.Options{
		Size:    27,
		DPI:     72,
		Hinting: font.HintingFull,
	})

	return widget.NewText(
		widget.TextOpts.Text(text, face, colornames.Gray),
	)
}

func makeButton(text string, f widget.ButtonClickedHandlerFunc) *widget.Button {
	buttonImage := &widget.ButtonImage{
		Idle:    image.NewNineSliceColor(color.NRGBA{R: 170, G: 170, B: 180, A: 255}),
		Hover:   image.NewNineSliceColor(color.NRGBA{R: 130, G: 130, B: 150, A: 255}),
		Pressed: image.NewNineSliceColor(color.NRGBA{R: 100, G: 100, B: 120, A: 255}),
	}

	ttfFont, err := truetype.Parse(goregular.TTF)
	if err != nil {
		log.Fatal(err)
	}

	face := truetype.NewFace(ttfFont, &truetype.Options{
		Size:    32,
		DPI:     72,
		Hinting: font.HintingFull,
	})

	return widget.NewButton(
		// set general widget options
		widget.ButtonOpts.WidgetOpts(
			// instruct the container's anchor layout to center the button both horizontally and vertically
			widget.WidgetOpts.LayoutData(widget.AnchorLayoutData{
				HorizontalPosition: widget.AnchorLayoutPositionStart,
				VerticalPosition:   widget.AnchorLayoutPositionStart,
			}),
		),

		// specify the images to use
		widget.ButtonOpts.Image(buttonImage),

		widget.ButtonOpts.Text(text, face, &widget.ButtonTextColor{
			Idle: color.NRGBA{0xdf, 0xf4, 0xff, 0xff},
		}),

		// specify that the button's text needs some padding for correct display
		widget.ButtonOpts.TextPadding(widget.Insets{
			Left:   30,
			Right:  30,
			Top:    5,
			Bottom: 5,
		}),

		// add a handler that reacts to clicking the button
		widget.ButtonOpts.ClickedHandler(f),
	)
}
