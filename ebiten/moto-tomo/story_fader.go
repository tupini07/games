package main

import (
	"image/color"
	"strings"
	"time"

	"golang.org/x/image/colornames"

	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/inpututil"
	"github.com/hajimehoshi/ebiten/v2/text"
	ebivec "github.com/hajimehoshi/ebiten/v2/vector"
	"github.com/solarlune/gocoro"
	"github.com/tupini07/moto-tomo/logging"
)

var storyNodes = map[int][]string{
	0: {
		"have you heard about the AMULET OF YENDOR? well, this is not that story.\n\nlet me tell you of the events as i understand them.",
		"you arrived late last night with a package for the wizard.\n\nhe invited you to stay for the night since it was pouring rain outside.",
		"you woke up in the middle of the night with a pressing need to go to the bathroom. but you soon got lost.\n\nthe corridors were all wrong, not at all how you remembered them.",
		"\n\n\n\neventually you opened a door and fell into a dark pit.\n\n\nand now here you are!",
		"it's nice to receive visitors in the dungeon. i'm supposed to make sure you never escape.\n\nbut that's not very fun, is it?",
		"so i'll tell you what.\n\ni'll give you a chance to escape.\n\nif you can find your way out, i'll let you go!",
		"\n\n\n\nbut if you die, i'll have to take your soul. deal?",
		"don't worry, i'll let you retry each room as many times as you want.\n\n\ni'm not a monster.",
		"you'll only really die when you give up.\n\nso don't give up!",
	},
	1: {
		"don't you wonder what the wizard is doing down here?\n\n\ni don't know either, but i'm sure it's something very important.",
		"i'm sure he's not just playing with his magic toys.\n\n\nhe's a very serious wizard.",
	},
	2: {
		"you know, i don't really like my job.\n\n\ni'd rather be a baker. or a florist. or a baker-florist.",
		"i'd bake cakes and decorate them with flowers.\n\n\nwouldn't that be nice?",
		"i'd bake a cake for you too, if you escaped.\n\n\nbut you won't, so i won't have to.",
	},
	3: {
		"i'm not sure why the wizard keeps all these monsters around.\n\n\nthey're not very nice.",
		"i think he's trying to train them to be nice.\n\n\nbut i don't think it's working.",
	},
	4: {
		"you know, maybe if found the exit, i could escape too.\n\n\ni'm not sure where it is though.",
		"it would be you and me against the world.\n\n\nwe could be friends.",
		"go on advneture together.\n\n\nmaybe open a bakery.",
	},
	5: {
		"i wonder what was in that package you delivered.\n\n\ni hope it wasn't a bomb.",
		"i don't think it was a bomb.\n\n\ni think it was a gift.",
	},
}

type StoryFader struct {
	overlayAlpha int
	storyFrames  []string
	coroutine    gocoro.Coroutine
}

func NewStoryFader(frames []string) *StoryFader {
	if len(frames) == 0 {
		panic("NewStoryFader was called without any frames!")
	}

	coroutine := gocoro.NewCoroutine()
	storyFader := &StoryFader{
		overlayAlpha: 0,
		storyFrames:  frames,
		coroutine:    coroutine,
	}

	coroutine.Run(func(exe *gocoro.Execution) {
		logging.Debug("StoryFader coroutine started")

		storyFader.overlayAlpha = 0

		for len(storyFader.storyFrames) > 0 {
			// wrap current text. At most 30 characters fit in the screen but we
			// want to break words respecting whitespaces
			currentFrame := storyFader.storyFrames[0]
			frameLines := strings.Split(currentFrame, "\n")
			conditionedFrameLines := make([]string, 0)

			for _, line := range frameLines {
				if len(line) > 30 {
					conditionedLine := ""
					words := strings.Split(line, " ")
					currentFrame = ""
					currentLine := ""
					for _, word := range words {
						if len(currentLine)+len(word) > 30 {
							conditionedLine += currentLine + "\n"
							currentLine = ""
						}
						currentLine += word + " "
					}

					if len(currentLine) > 0 {
						conditionedLine += currentLine
					}

					conditionedFrameLines = append(conditionedFrameLines, conditionedLine)
				} else {
					conditionedFrameLines = append(conditionedFrameLines, line)
				}
			}

			currentFrame = strings.Join(conditionedFrameLines, "\n")
			storyFader.storyFrames[0] = currentFrame

			for storyFader.overlayAlpha < 255 {
				storyFader.overlayAlpha += 5
				exe.Yield()
			}
			storyFader.overlayAlpha = 255

			// TODO, this should be a function of the current frame's text
			for !inpututil.IsKeyJustPressed(ebiten.KeySpace) && !inpututil.IsKeyJustPressed(ebiten.KeyS) {
				exe.Yield()
			}

			if inpututil.IsKeyJustPressed(ebiten.KeyS) {
				// skip story
				storyFader.storyFrames = []string{}
				break
			}

			for storyFader.overlayAlpha > 0 {
				storyFader.overlayAlpha -= 10
				exe.Yield()
			}
			storyFader.overlayAlpha = 0

			storyFader.storyFrames = storyFader.storyFrames[1:]
		}

		exe.YieldTime(1 * time.Second)
	})

	return storyFader
}

func (sf *StoryFader) Draw(screen *ebiten.Image) {
	if len(sf.storyFrames) > 0 {
		overlayImage := ebiten.NewImage(screen.Bounds().Dx(), screen.Bounds().Dy())

		ebivec.DrawFilledRect(overlayImage,
			0, 0,
			float32(screen.Bounds().Dx()),
			float32(screen.Bounds().Dy()),
			color.Black,
			false,
		)

		currentFrame := sf.storyFrames[0]
		text.Draw(overlayImage, currentFrame, smallFontFace, 6, 20, color.White)

		if sf.overlayAlpha == 255 {
			if len(sf.storyFrames) > 1 {
				text.Draw(overlayImage, "press   to skip story", smallFontFace, 34, 112, colornames.Lightslategray)
				text.Draw(overlayImage, "      s", smallFontFace, 34, 112, colornames.Lightgray)
			}

			text.Draw(overlayImage, "press       to continue", smallFontFace, 34, 120, colornames.Lightslategray)
			text.Draw(overlayImage, "      space", smallFontFace, 34, 120, colornames.Lightgray)
		}

		ops := &ebiten.DrawImageOptions{}
		ops.ColorScale.ScaleAlpha(float32(sf.overlayAlpha) / 255.)
		screen.DrawImage(overlayImage, ops)
	}

}
