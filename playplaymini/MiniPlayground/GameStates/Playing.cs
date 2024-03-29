using BenMakesGames.PlayPlayMini;
using BenMakesGames.PlayPlayMini.UI.Services;
using BenMakesGames.PlayPlayMini.GraphicsExtensions;
using BenMakesGames.PlayPlayMini.Services;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Input;
using BenMakesGames.PlayPlayMini.UI.UIElements;
using BenMakesGames.PlayPlayMini.UI.Model;
using BenMakesGames.PlayPlayMini.Attributes.DI;
using MiniPlayground.Entities;

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

    private readonly SimpleCamera _camera = new(_graphics);

    public override void Draw(GameTime gameTime)
    {
        _graphics.Clear(Color.DarkSlateGray);
        _graphics.DrawWavyText("Font", 4, 16, gameTime, $"Select one!", Color.Gray);

        _ui.AlwaysDraw(gameTime);
        _ui.AlwaysDraw(gameTime);

        _graphics.DrawWavyText(
            "Font",
            _mouse.X - 35,
            _mouse.Y - 10,
            gameTime,
            $"x:{_mouse.X}, y:{_mouse.Y}",
            Color.White
        );
        _mouse.Draw(gameTime);
    }

    public override void Update(GameTime gameTime)
    {
        _ui.ActiveUpdate(gameTime);

        if (_keyboard.KeyDown(Keys.Left))
        {
            _camera.position.X -= 0.2f;
        }
        else if (_keyboard.KeyDown(Keys.Right))
        {
            _camera.position.X += 0.2f;
        }

        if (_keyboard.KeyDown(Keys.Up))
        {
            _camera.position.Y -= 0.2f;
        }
        else if (_keyboard.KeyDown(Keys.Down))
        {
            _camera.position.Y += 0.2f;
        }

        if (_keyboard.KeyDown(Keys.Q))
        {
            _camera.rotation -= 0.001f;
        }
        else if (_keyboard.KeyDown(Keys.E))
        {
            _camera.rotation += 0.001f;
        }

        if (_keyboard.KeyDown(Keys.W))
        {
            _camera.zoom += 0.001f;
        }
        else if (_keyboard.KeyDown(Keys.S))
        {
            _camera.zoom -= 0.001f;
        }

        if (_keyboard.PressedKey(Keys.R))
        {
            _camera.ResetTransform();
        }

        _camera.SetTransformMatrix();
    }

    public override void Enter()
    {
        _mouse.UseCustomCursor("Cursor", (3, 1));

        List<IUIElement> elements = [
            new Label(_ui, 4, 16, "Select one!", Color.White)
        ];

        elements.Add(new Button(_ui, 4, elements.Last().Y + elements.Last().Height + 8, "Circle bash",
            clickHandler: (e) =>
            {
                _gsm.ChangeState<CircleBash>();
            }
        ));

        elements.Add(new Button(_ui, 4, elements.Last().Y + elements.Last().Height + 2, "Parade",
            clickHandler: (e) =>
            {
                _gsm.ChangeState<CircleParade>();
            }
        ));

        elements.Add(new Button(_ui, 4, elements.Last().Y + elements.Last().Height + 2, "Sandbox",
            clickHandler: (e) =>
            {
                _gsm.ChangeState<PhysicsSandbox>();
            }
        ));

        elements.Add(new Button(_ui, 4, elements.Last().Y + elements.Last().Height + 2, "Particles",
            clickHandler: (e) =>
            {
                _gsm.ChangeState<Particles>();
            }
        ));

        // and the window to the UI canvas:
        _ui.Canvas.AddUIElements(elements);
    }


    public override void Leave()
    {
        _camera.UnsetTransform();
    }
}
