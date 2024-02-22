using Autofac;
using BenMakesGames.PlayPlayMini;
using BenMakesGames.PlayPlayMini.Model;
using MiniPlayground.GameStates;

// TODO: any pre-req setup, ex:
/*
 * var appData = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);
 * var appDataGameDirectory = @$"{appData}{Path.DirectorySeparatorChar}MiniPlayground";
 *
 * Directory.CreateDirectory(appDataGameDirectory);
 */

var gsmBuilder = new GameStateManagerBuilder();


gsmBuilder
    .SetWindowSize(1920 / 4, 1080 / 4, 2) // this is using a 2x zoom
    .SetInitialGameState<Startup>()

    // TODO: set a better window title
    .SetWindowTitle("MiniPlayground")

    // TODO: add any resources needed (refer to PlayPlayMini documentation for more info)
    .AddAssets(new IAsset[]
    {
        new FontMeta("Font", "Graphics/Font", 6, 8),
        new PictureMeta("Cursor", "Graphics/Cursor", true),

        new SpriteSheetMeta("Button", "Graphics/Button", 14, 14),

        // new FontMeta(...)
        // new PictureMeta(...)
        // new SpriteSheetMeta(...)
        // new SongMeta(...)
        // new SoundEffectMeta(...)
    })

    // TODO: any additional service registration (refer to PlayPlayMini and/or Autofac documentation for more info)
    .AddServices((container, config) =>
    {

    })
;

gsmBuilder.Run();
