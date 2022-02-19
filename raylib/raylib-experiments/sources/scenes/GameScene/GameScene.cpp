#include <iostream>

#include <raylib.h>
#include <LDtkLoader/World.hpp>

#include <Constants.hpp>
#include "GameScene.hpp"
#include "../Scenes.hpp"

GameScene::GameScene()
{
	player = new Player();

	ldtkWorld = new ldtk::World();
	ldtkWorld->loadFromFile(AppConstants::GetAssetPath("world.ldtk"));

	current_level = -1;
	set_selected_level(0);
}

GameScene::~GameScene()
{
	delete ldtkWorld;
	delete player;

	UnloadTexture(renderedLevelTexture);
	UnloadTexture(currentTilesetTexture);
}

void GameScene::draw()
{
	ClearBackground(RAYWHITE);

	auto renderTexture = LoadRenderTexture(GameConstants::WorldWidth, GameConstants::WorldHeight);

	BeginTextureMode(renderTexture);
	DrawTextureRec(renderedLevelTexture,
				   {0, 0, (float)renderedLevelTexture.width, (float)-renderedLevelTexture.height},
				   {0, 0}, WHITE);
	player->draw();
	EndTextureMode();

	// NOTE: Render texture must be y-flipped due to default OpenGL coordinates (left-bottom)
	DrawTexturePro(renderTexture.texture,
				   {0, 0, (float)renderTexture.texture.width, -(float)renderTexture.texture.height},
				   {0, 0, AppConstants::ScreenWidth, AppConstants::ScreenHeight},
				   {0, 0}, 0, WHITE);
}

Scenes GameScene::update(float dt)
{
	player->update(dt);

	return Scenes::NONE;
}

void GameScene::set_selected_level(int lvl)
{
	// unload current tileset texture if necessary
	if (current_level >= 0)
	{
		UnloadTexture(currentTilesetTexture);
	}

	current_level = lvl;

	currentLdtkLevel = &ldtkWorld->getLevel(current_level);

	using namespace std;
	cout << "----------------------------------------------" << endl;
	cout << "Loaded LDTK map with " << ldtkWorld->allLevels().size() << " levels in it" << endl;
	cout << "The loaded level is " << current_level << " and it has " << currentLdtkLevel->allLayers().size() << " layers" << endl;
	for (auto &&layer : currentLdtkLevel->allLayers())
	{
		cout << "  - " << layer.getName() << endl;
	}

	auto testTileLayerTileset = currentLdtkLevel->getLayer("TileLayer").getTileset();
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
			currentTilesetTexture = LoadTexture(AppConstants::GetAssetPath(layer.getTileset().path).c_str());
			// if it is a tile layer then draw every tile to the frame buffer
			for (auto &&tile : layer.allTiles())
			{
				auto source_pos = tile.texture_position;
				auto target_pos = tile.position;
				auto tile_size = float(layer.getTileset().tile_size);

				Rectangle source_rect = {
					.x = float(source_pos.x),
					.y = float(source_pos.y),
					.width = tile.flipX ? -tile_size : tile_size,
					.height = tile.flipY ? -tile_size : tile_size,
				};

				DrawTextureRec(currentTilesetTexture, source_rect, {float(target_pos.x), float(target_pos.y)}, WHITE);
			}
		}
	}

	// get entity positions
	cout << "Entities in level:" << endl;
	for (auto &&entity : currentLdtkLevel->getLayer("Entities").allEntities())
	{
		cout << "  - " << entity.getName() << endl;

		if (entity.getName() == "Player")
		{
			player->init_for_level(&entity);
		}
	}

	// create physics?

	EndTextureMode();

	renderedLevelTexture = renderTexture.texture;
}