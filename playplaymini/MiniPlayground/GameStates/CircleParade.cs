
using BenMakesGames.PlayPlayMini;
using BenMakesGames.PlayPlayMini.GraphicsExtensions;
using BenMakesGames.PlayPlayMini.Services;
using Microsoft.Xna.Framework;
using MiniPlayground.Utils;

namespace MiniPlayground.GameStates;

class CircleParade(
    GraphicsManager _graphics,
    GameStateManager _gsm,
    KeyboardManager _keyboard
) : GameState
{
    private float _colorModifier = 1000f;
    private int _backgroundIndex = 0;

    private readonly Color[] _backgroundColors = [
        Color.DarkGoldenrod,
        Color.DarkMagenta,
        Color.DarkOrchid,
        Color.DarkSlateBlue,
        Color.DarkViolet,
        Color.BlanchedAlmond,
    ];

    public override void Enter()
    {
    }

    public override void Leave()
    {
    }

    public override void Update(GameTime gameTime)
    {
        _colorModifier += (float)(gameTime.ElapsedGameTime.TotalSeconds * 0.1);

        if (_keyboard.PressedAnyKey())
        {
            if (Random.Shared.NextSingle() > 0.5)
            {
                _colorModifier += 1;
            }
            else
            {
                _backgroundIndex = (_backgroundIndex + 1) % _backgroundColors.Length;
            }
        }

        GameStateUtils.HandleCommonKeybindings(_gsm, _keyboard, _graphics);
    }

    public override void Draw(GameTime gameTime)
    {
        _graphics.Clear(_backgroundColors[_backgroundIndex]);

        var yOffset = 0;

        // draw columns of staggered circles to fill the screen. Use cosine
        // to make the circles move up and down.
        var radius = 14;
        var gap = 3;
        for (var x = 0; x < (_graphics.Width + radius * 2); x += (radius * 2) + gap)
        {
            for (var y = 0 + yOffset; y < (_graphics.Height + radius * 2); y += (radius * 2) + gap)
            {
                int index = Math.Abs((int)((Math.Sin(x) * _colorModifier) + (Math.Cos(y) * _colorModifier))) % Pallette.Pico8Pallette.Length;
                var outlineColor = Pallette.Pico8Pallette[index];
                var fillColor = Pallette.Pico8Pallette[(index + 1) % Pallette.Pico8Pallette.Length];

                var yMod = (float)Math.Cos(gameTime.TotalGameTime.TotalSeconds + x);
                _graphics.DrawFilledCircle(x, (int)(y + yMod * 10), radius, fillColor);
                _graphics.DrawCircle(x, (int)(y + yMod * 10), radius, outlineColor);
            }
        }
    }
}