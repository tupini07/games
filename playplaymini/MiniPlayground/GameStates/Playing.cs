using BenMakesGames.PlayPlayMini;
using BenMakesGames.PlayPlayMini.GraphicsExtensions;
using BenMakesGames.PlayPlayMini.Services;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Input;

namespace MiniPlayground.GameStates;

// sealed classes execute faster than non-sealed, so always seal your game states!
public sealed class Playing(
    GraphicsManager graphics,
    GameStateManager gsm,
    MouseManager mouse,
    KeyboardManager keyboard
) : GameState
{
    private GraphicsManager _graphics { get; } = graphics;
    private KeyboardManager _keyboard { get; } = keyboard;
    private GameStateManager _GSM { get; } = gsm;
    private MouseManager _mouse { get; } = mouse;


    // overriding lifecycle methods is optional; feel free to delete any overrides you're not using.
    // note: you do NOT need to call the `base.` for lifecycle methods. so save some CPU cycles,
    // and don't call them :P

    public override void Draw(GameTime gameTime)
    {
        // TODO: draw game scene (refer to PlayPlayMini documentation for more info)

        _graphics.Clear(Color.DarkSlateGray);

        _graphics.DrawText("Font", _graphics.Width / 2 - 30, _graphics.Height / 2 - 4, "Oh, hi! :D", Color.White);
        _graphics.DrawText("Font", 10, (_graphics.Height / 3) * 2, "Press X to continue", Color.FloralWhite);

        _graphics.DrawWavyText("Font", _mouse.X - 35, _mouse.Y - 10, gameTime, $"x:{_mouse.X}, y:{_mouse.Y}", Color.White);

        _mouse.Draw(gameTime);
    }

    public override void Update(GameTime gameTime)
    {
        if (_keyboard.PressedKey(Keys.X))
        {
            Console.WriteLine("Hey! You just pressed the X key! Good for you");
            _GSM.ChangeState<BabuMaster>();
        }
    }

    public override void Enter()
    {
    }

    public override void Leave()
    {
    }
}
