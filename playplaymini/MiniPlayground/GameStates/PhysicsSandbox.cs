using BenMakesGames.PlayPlayMini;
using BenMakesGames.PlayPlayMini.GraphicsExtensions;
using BenMakesGames.PlayPlayMini.Services;
using Genbox.VelcroPhysics.Collision.ContactSystem;
using Genbox.VelcroPhysics.Collision.Handlers;
using Genbox.VelcroPhysics.Collision.Shapes;
using Genbox.VelcroPhysics.Definitions;
using Genbox.VelcroPhysics.Dynamics;
using Genbox.VelcroPhysics.Factories;
using Genbox.VelcroPhysics.Utilities;
using Microsoft.Xna.Framework;
using Microsoft.Xna.Framework.Input;
using MiniPlayground.Extensions;
using MiniPlayground.Utils;


namespace MiniPlayground.GameStates;


class PhysicsSandbox(
    GraphicsManager _graphics,
    GameStateManager _gsm,
    KeyboardManager _keyboard
) : GameState
{
    private readonly World _world = new(new Vector2(0, 9.8f * 20));

    class BodyUserData()
    {
        public Color InnerColor { get; set; }
        public Color OuterColor { get; set; }
    }

    public override void Enter()
    {
        // create ceiling
        CreateRectangleBody(
            new Vector2(_graphics.Width / 2, 5), 
            new Vector2(_graphics.Width, 10));

        // create a floor
        CreateRectangleBody(
            new Vector2(_graphics.Width / 2, _graphics.Height - 5), 
            new Vector2(_graphics.Width, 10));

        // create left wall
        CreateRectangleBody(
            new Vector2(5, _graphics.Height / 2), 
            new Vector2(10, _graphics.Height));

        // create right wall
        CreateRectangleBody(
            new Vector2(_graphics.Width - 5, _graphics.Height / 2), 
            new Vector2(10, _graphics.Height));

        // create 20 random positioned balls
        for (int i = 0; i < 20; i++)
        {
            CreateCircleBody(
                new Vector2(Random.Shared.Next(0, _graphics.Width), Random.Shared.Next(0, _graphics.Height)), 
                (float)Random.Shared.NextInt64(10, 30));
        }
    }

    public override void Leave()
    {
    }

    public override void Update(GameTime gameTime)
    {
        _world.Step((float)gameTime.ElapsedGameTime.TotalSeconds);

        if (_keyboard.PressedKey(Keys.Space))
        {
            // apply random force to random body
            Console.WriteLine("Applying random force to random body");
            
            // TODO should only pick from Circle bodies, not the walls
            var body = Random.Shared.Sample(_world.BodyList);
            body.ApplyForce(new Vector2(0, -100000000));
        }

        GameStateUtils.HandleCommonKeybindings(_gsm, _keyboard, _graphics);
    }

    public override void Draw(GameTime gameTime)
    {
        _graphics.Clear(Color.Wheat);

        foreach (var body in _world.BodyList)
        {
            var position = body.Position;
            var shape = body.FixtureList[0].Shape;

            if (shape is CircleShape circle)
            {
                _graphics.DrawFilledCircle(
                    (int)position.X,
                    (int)position.Y,
                    (int)circle.Radius,
                    ((BodyUserData)body.UserData).InnerColor
                );

                _graphics.DrawCircle(
                    (int)position.X,
                    (int)position.Y,
                    (int)circle.Radius,
                    ((BodyUserData)body.UserData).OuterColor
                );
            }
            else if (shape is PolygonShape polygon)
            {
                var vertices = polygon.Vertices;
                var width = vertices[2].X * 2;
                var height = vertices[2].Y * 2;
                var x = position.X - width / 2;
                var y = position.Y - height / 2;

                _graphics.DrawRectangle((int)x, (int)y, (int)width, (int)height, Color.White);
            }
        }
    }

    private void CreateRectangleBody(Vector2 position, Vector2 size)
    {
        var body = BodyFactory.CreateRectangle(
            world: _world,
            width: size.X,
            height: size.Y,
            density: 1f,
            position: position,
            bodyType: BodyType.Static
        );

        body.OnCollision += (Fixture fixtureA, Fixture fixtureB, Contact contact) =>
        {
            // Console.WriteLine("Rectangle collided!");
        };
    }

    private void CreateCircleBody(Vector2 position, float radius)
    {
        var body = BodyFactory.CreateCircle(
            world: _world,
            radius: 10,
            density: 1f,
            position: position,
            bodyType: BodyType.Dynamic
        );

        body.Restitution = 0.99f;

        body.UserData = new BodyUserData
        {
            InnerColor = Random.Shared.Sample(Pallette.Pico8Pallette),
            OuterColor = Random.Shared.Sample(Pallette.Pico8Pallette),
        };

        body.OnCollision += (Fixture fixtureA, Fixture fixtureB, Contact contact) =>
        {
            ((BodyUserData)body.UserData).InnerColor = Random.Shared.Sample(Pallette.Pico8Pallette);
            ((BodyUserData)body.UserData).OuterColor = Random.Shared.Sample(Pallette.Pico8Pallette);
        };
    }
}