#include <raylib.h>
#include <iostream>

#include <Constants.hpp>
#include "GameScene.hpp"
#include "../Scenes.hpp"

GameScene::GameScene()
{
    ldtkWorld = new ldtk::World();
    ldtkWorld->loadFromFile(AppConstants::GetAssetPath("world.ldtk"));

    current_level = 0;
    set_selected_level();

    player = new Player();
}

GameScene::~GameScene()
{
    delete ldtkWorld;
    delete player;
}

void GameScene::draw()
{
    ClearBackground(RAYWHITE);

    // NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
    DrawTextureRec(renderedLevelTexture, (Rectangle){0, 0, (float)renderedLevelTexture.width, (float)-renderedLevelTexture.height}, (Vector2){0.0f, 0.0f}, WHITE);
    player->draw();
}

Scenes GameScene::update(float dt)
{
    player->update(dt);

    return NONE;
}

void GameScene::set_selected_level()
{
    currentLdtkLevel = &ldtkWorld->getLevel(current_level);

    using namespace std;
    cout << "----------------------------------------------" << endl;
    cout << "Loaded LDTK map with " << ldtkWorld->allLevels().size() << " levels in it" << endl;
    cout << "The loaded level is " << current_level << " and it has " << currentLdtkLevel->allLayers().size() << " layers" << endl;
    auto testTileLayerTileset = currentLdtkLevel->getLayer("Tiles").getTileset();
    cout << "The path to the tile layer tileset is: " << testTileLayerTileset.path << endl;
    cout << "----------------------------------------------" << endl;

    auto levelSize = currentLdtkLevel->size;
    auto renderTexture = LoadRenderTexture(levelSize.x, levelSize.y);

    BeginTextureMode(renderTexture);
    // draw all tileset layers
    for (auto &&layer : currentLdtkLevel->allLayers())
    {
        if (layer.hasTileset())
        {
            auto tilemapTexture = LoadTexture(AppConstants::GetAssetPath(layer.getTileset().path).c_str());
            // if it is a tile layer then draw every tile to the frame buffer
            for (auto &&tile : layer.allTiles())
            {
                auto source_pos = tile.texture_position;
                auto target_pos = tile.position;
                auto tile_size = float(layer.getTileset().tile_size);

                Rectangle source_rect = {
                    .x = float(source_pos.x),
                    .y = float(source_pos.y),
                    .width = tile_size,
                    .height = tile_size};

                DrawTextureRec(tilemapTexture, source_rect, {float(target_pos.x), float(target_pos.y)}, WHITE);
            }
        }
    }

    DrawText("potato", 0, 0, 20, RED);
    EndTextureMode();

    renderedLevelTexture = renderTexture.texture;
}