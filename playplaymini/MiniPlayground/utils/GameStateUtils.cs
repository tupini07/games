using System.Reflection;
using BenMakesGames.PlayPlayMini;
using BenMakesGames.PlayPlayMini.Services;
using Microsoft.Xna.Framework.Input;
using MiniPlayground.GameStates;

namespace MiniPlayground.Utils;

static class GameStateUtils
{
    public static void HandleCommonKeybindings(GameStateManager gsm, KeyboardManager keyboard, GraphicsManager graphics)
    {
        if (keyboard.KeyDown(Keys.LeftControl))
        {
            if (keyboard.PressedKey(Keys.F4))
            {
                gsm.ChangeState<Playing>();
            }

            if (keyboard.PressedKey(Keys.F11))
            {
                graphics.SetFullscreen(!graphics.FullScreen);
            }

            if (keyboard.PressedKey(Keys.F5))
            {
                // reload the current state
                gsm.ChangeState(gsm.CurrentState.GetType());
            }
        }
    }
}
