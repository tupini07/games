using BenMakesGames.PlayPlayMini;
using BenMakesGames.PlayPlayMini.UI.Services;
using BenMakesGames.PlayPlayMini.GraphicsExtensions;
using BenMakesGames.PlayPlayMini.Services;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Input;
using BenMakesGames.PlayPlayMini.UI.UIElements;
using BenMakesGames.PlayPlayMini.UI.Model;
using BenMakesGames.PlayPlayMini.Attributes.DI;

namespace MiniPlayground.GameStates;

[AutoRegister(InstanceOf = typeof(UIThemeProvider))]
public sealed class ThemeProvider : UIThemeProvider
{
    protected override Theme CurrentTheme { get; set; } = new(
        WindowColor: Color.Orange,
        FontName: "Font",
        ButtonSpriteSheetName: "Button",
        ButtonLabelColor: Color.White,
        ButtonLabelDisabledColor: Color.Gray,
        CheckboxSpriteSheetName: "Button"
    );
}

// sealed classes execute faster than non-sealed, so always seal your game states!
public sealed class Playing(
    GraphicsManager _graphics,
    GameStateManager _gsm,
    MouseManager _mouse,
    KeyboardManager _keyboard,
    UIService _ui
) : GameState
{

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

        _ui.AlwaysDraw(gameTime);
        _ui.AlwaysDraw(gameTime);

        _mouse.Draw(gameTime);
    }

    public override void Update(GameTime gameTime)
    {
        if (_keyboard.PressedKey(Keys.X))
        {
            Console.WriteLine("Hey! You just pressed the X key! Good for you");
            _gsm.ChangeState<BabuMaster>();
            return;
        }

        _ui.ActiveUpdate(gameTime);
    }

    public override void Enter()
    {
        _mouse.UseCustomCursor("Cursor", (3, 1));

        var title = new Label(_ui, 4, 16, "Select one!", Color.WhiteSmoke);

        var printSomething = new Button(_ui, 4, title.Y + title.Height + 2, "Print something!",
            clickHandler: (e) =>
            {
                Console.WriteLine("Hey! You just pressed the resume button! Good for you");
            });

        var goToBabu = new Button(_ui, 4, printSomething.Y + printSomething.Height + 2, "Go to Babu!",
            clickHandler: (e) =>
            {
                _gsm.ChangeState<BabuMaster>();
            });

        // and the window to the UI canvas:
        _ui.Canvas.AddUIElements(title, printSomething, goToBabu);
    }


    public override void Leave()
    {
    }
}
