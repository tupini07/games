using BenMakesGames.PlayPlayMini;
using BenMakesGames.PlayPlayMini.GraphicsExtensions;
using BenMakesGames.PlayPlayMini.Services;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Input;

namespace MiniPlayground.GameStates;


public sealed class BabuMaster(
    GraphicsManager graphics,
    GameStateManager gsm,
    KeyboardManager keyboard
) : GameState
{
    private GraphicsManager _graphics { get; } = graphics;
    private KeyboardManager _keyboard { get; } = keyboard;
    private GameStateManager _GSM { get; } = gsm;
    private List<Circle> circles = new();


    public override void Enter()
    {
        // _graphics.SetFullscreen(true);
    }

    public override void Leave()
    {
        // _graphics.SetFullscreen(false);
    }

    class Circle(int x, int y, float radius, double decreaseSpeed, Color inner, Color outline)
    {
        public bool isDead { get { return radius <= 0; } }

        public void Update(GameTime gameTime)
        {
            radius -= (float)(decreaseSpeed * gameTime.ElapsedGameTime.TotalMilliseconds);
        }

        public void Draw(GraphicsManager _graphics)
        {
            _graphics.DrawFilledCircle(x, y, (int)radius, inner);
            _graphics.DrawCircle(x, y, (int)radius, outline);
        }
    }


    public override void Draw(GameTime gameTime)
    {
        _graphics.Clear(Color.Black);
        circles.ForEach(c => c.Draw(_graphics));
    }

    public override void Update(GameTime gameTime)
    {
        if (_keyboard.PressedAnyKey())
        {
            var randomPosX = Random.Shared.Next(0, _graphics.Width);
            var randomPosY = Random.Shared.Next(0, _graphics.Height);
            var randomRadius = Random.Shared.Next(10, 100);
            var randomDecreaseSpeed = Random.Shared.NextDouble() * 0.1;
            randomDecreaseSpeed = Math.Clamp(randomDecreaseSpeed, 0.01, 0.4);

            Color[] palette = [
                new Color(0x1D2B53),
                new Color(0x7E2553),
                new Color(0x008751),
                new Color(0xAB5236),
                new Color(0x5F574F),
                new Color(0xC2C3C7),
                new Color(0xFFF1E8),
                new Color(0xFF004D),
                new Color(0xFFA300),
                new Color(0xFFEC27),
                new Color(0x00E436),
                new Color(0x29ADFF),
                new Color(0x83769C),
                new Color(0xFF77A8),
                new Color(0xFFCCAA),
                new Color(0x1D, 0x2B, 0x53),
                new Color(0x7E, 0x25, 0x53),
                new Color(0x00, 0x87, 0x51),
                new Color(0xAB, 0x52, 0x36),
                new Color(0x5F, 0x57, 0x4F),
                new Color(0xC2, 0xC3, 0xC7),
                new Color(0xFF, 0xF1, 0xE8),
                new Color(0xFF, 0x00, 0x4D),
                new Color(0xFF, 0xA3, 0x00),
                new Color(0xFF, 0xEC, 0x27),
                new Color(0x00, 0xE4, 0x36),
                new Color(0x29, 0xAD, 0xFF),
                new Color(0x83, 0x76, 0x9C),
                new Color(0xFF, 0x77, 0xA8),
                new Color(0xFF, 0xCC, 0xAA),
            ];

            var colorFill = palette[Random.Shared.Next(0, palette.Length)];
            var colorOutline = palette[Random.Shared.Next(0, palette.Length)];

            circles.Add(new Circle(
                randomPosX,
                randomPosY,
                randomRadius,
                randomDecreaseSpeed,
                colorFill,
                colorOutline
            ));
        }

        circles.ForEach(c => c.Update(gameTime));
        circles.RemoveAll(c => c.isDead);


        if (_keyboard.KeyDown(Keys.LeftControl) && _keyboard.PressedKey(Keys.F4))
        {
            _GSM.ChangeState<Playing>();
        }

        if (_keyboard.PressedKey(Keys.F11))
        {
            _graphics.SetFullscreen(!_graphics.FullScreen);
        }
    }
}