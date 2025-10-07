using System.Numerics;
using Foster.Framework;
using FosterImGui;
using ImGuiNET;
class Game : Module
{
    private const float Acceleration = 1200;
    private const float Friction = 500;
    private const float MaxSpeed = 800;

    private readonly Batcher batch = new();
    private readonly Texture texture = new Texture(new Image(128, 128, Color.Blue));
    private Vector2 pos = new(128, 128);
    private Vector2 posSquare = new Vector2(App.WidthInPixels, App.HeightInPixels) / 2;
    private Vector2 speed = new();

    private SpriteFont font = null!;

    private float mouseCircleRadius = 16;
    private bool showingImgui = true;


    public override void Startup()
    {
        App.Title = $"Somsething Else {App.Width}x{App.Height} : {App.WidthInPixels}x{App.HeightInPixels}";
        App.VSync = true;
        // App.MouseVisible = false;
        // capture the mouse

        font = new SpriteFont(Path.Join("Assets", "monogram.ttf"), 32);
        Renderer.Startup();
    }

    public override void Shutdown()
    {
        Renderer.Shutdown();
    }

    public override void Update()
    {
        if (Input.Keyboard.Pressed(Keys.Space))
        {
            // reset position
            pos = new Vector2(Random.Shared.Next(0, App.WidthInPixels), Random.Shared.Next(0, App.HeightInPixels));
        }

        if (Input.Keyboard.Down(Keys.Left))
            speed.X -= Acceleration * Time.Delta;
        if (Input.Keyboard.Down(Keys.Right))
            speed.X += Acceleration * Time.Delta;
        if (Input.Keyboard.Down(Keys.Up))
            speed.Y -= Acceleration * Time.Delta;
        if (Input.Keyboard.Down(Keys.Down))
            speed.Y += Acceleration * Time.Delta;

        if (Input.Keyboard.Down(Keys.A))
            posSquare.X -= Acceleration * Time.Delta;
        if (Input.Keyboard.Down(Keys.D))
            posSquare.X += Acceleration * Time.Delta;
        if (Input.Keyboard.Down(Keys.W))
            posSquare.Y -= Acceleration * Time.Delta;
        if (Input.Keyboard.Down(Keys.S))
            posSquare.Y += Acceleration * Time.Delta;

        if (!Input.Keyboard.Down(Keys.Left, Keys.Right))
            speed.X = Calc.Approach(speed.X, 0, Time.Delta * Friction);
        if (!Input.Keyboard.Down(Keys.Up, Keys.Down))
            speed.Y = Calc.Approach(speed.Y, 0, Time.Delta * Friction);

        if (Input.Keyboard.Pressed(Keys.F4))
            App.Fullscreen = !App.Fullscreen;

        if (speed.Length() > MaxSpeed)
            speed = speed.Normalized() * MaxSpeed;

        if (Input.Mouse.Down(MouseButtons.Left))
            mouseCircleRadius = 64;
        else
            mouseCircleRadius = 16;

        pos += speed * Time.Delta;

        // bind the position to the screen
        pos = Vector2.Clamp(pos, new Vector2(64), new Vector2(App.WidthInPixels - 64, App.HeightInPixels - 64));
        posSquare = Vector2.Clamp(posSquare, new Vector2(64), new Vector2(App.WidthInPixels - 64, App.HeightInPixels - 64));

        // ----------------------
        if (Input.Keyboard.Pressed(Keys.F1))
            showingImgui = !showingImgui;

        App.MouseVisible = ImGui.IsWindowHovered(ImGuiHoveredFlags.AnyWindow);
        if (showingImgui)
        {
            Renderer.BeginLayout();

            ImGui.SetNextWindowSize(new Vector2(300, 200), ImGuiCond.Appearing);
            if (ImGui.Begin("ImgGui magic"))
            {
                // show an Image button
                if (ImGui.Button("a lable hoho"))
                    ImGui.OpenPopup("Image Button");

                // image buttton popup
                if (ImGui.BeginPopup("Image Button"))
                {
                    ImGui.Text("You pressed the Image Button!");
                    var imageId = Renderer.GetTextureID(texture);
                    ImGui.Image(imageId, new Vector2(128, 128));
                    ImGui.EndPopup();
                }

                ImGui.SliderFloat("Circle X", ref pos.X, 0, App.WidthInPixels);
                ImGui.SliderFloat("Circle Y", ref pos.Y, 0, App.HeightInPixels);

                // custom sprite batcher inside imgui window
                ImGui.Text("Some Foster Sprite Batching:");
                Renderer.BeginBatch(out var batch, out var bounds);

                batch.CheckeredPattern(bounds, 16, 16, Color.DarkGray, Color.Gray);
                batch.Circle(bounds.Center, 32, 16, Color.Red);
                Renderer.EndBatch();



            }
            ImGui.End();

            Renderer.EndLayout();
        }
    }

    public override void Render()
    {
        Graphics.Clear(0x44aa77);

        batch.PushMatrix(
            posSquare,
            Vector2.One,
            new Vector2(texture.Width, texture.Height) / 2,
            (float)Time.Duration.TotalSeconds * 4.0f);
        batch.Image(texture, Vector2.Zero, Color.White);
        batch.PopMatrix();

        batch.RectLine(new Rect(30, 30, 100, 100), 4, Color.Yellow);
        batch.RectDashed(new Rect(100, 100, 100, 100), 4, Color.Yellow, 10, (float)Time.Duration.TotalSeconds * 2.0f);

        var rect = new Rect(200, 200, 100, 100);
        var rectCenter = new Vector2(rect.X + rect.Width / 2, rect.Y + rect.Height / 2);
        var rectRadius = 48 * (float)Math.Abs(Math.Sin(Time.Duration.TotalSeconds));
        batch.RectRounded(rect, rectRadius, Color.Yellow);
        var text = $"{rectRadius:F2}";
        var textSize = font.SizeOf(text);
        var textPosition = new Vector2(rectCenter.X - textSize.X / 2, rectCenter.Y - textSize.Y / 2);
        batch.Text(font, text, textPosition, Color.Black);

        batch.Circle(new Circle(pos, 64), 16, Color.Red);
        batch.Circle(new Circle(Input.Mouse.Position, mouseCircleRadius), 16, Color.White);

        batch.Line(pos, pos + speed, 4, Color.White);

        batch.Render();
        batch.Clear();

        if (showingImgui)
        {
            Renderer.Render();
        }
    }
}