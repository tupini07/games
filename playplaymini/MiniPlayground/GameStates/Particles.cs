
using BenMakesGames.PlayPlayMini;
using BenMakesGames.PlayPlayMini.GraphicsExtensions;
using BenMakesGames.PlayPlayMini.Services;
using Microsoft.Xna.Framework;
using MiniPlayground.Utils;

namespace MiniPlayground.GameStates;

class Particles(
    GraphicsManager _graphics,
    GameStateManager _gsm,
    KeyboardManager _keyboard,
    MouseManager _mouse
) : GameState
{
    public override void Enter()
    {
        _mouse.UseSystemCursor();
    }

    public override void Leave()
    {
    }

    public override void Draw(GameTime gameTime)
    {
        _graphics.Clear(Color.Black);
    }

    public override void Update(GameTime gameTime)
    {
        GameStateUtils.HandleCommonKeybindings(_gsm, _keyboard, _graphics);
    }
}