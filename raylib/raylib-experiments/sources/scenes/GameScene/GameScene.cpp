#include <iostream>

#include <raylib.h>
#include <extras/physac.h>
#include <LDtkLoader/World.hpp>

#include <Constants.hpp>
#include "GameScene.hpp"
#include "../Scenes.hpp"

using namespace std;

GameScene::GameScene()
{
	InitPhysics();
	SetPhysicsGravity(0, 2);

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
	ClosePhysics();
}

void GameScene::draw()
{
	ClearBackground(RAYWHITE);
	DrawTextureRec(renderedLevelTexture,
				   {0, 0, (float)renderedLevelTexture.width, (float)-renderedLevelTexture.height},
				   {0, 0}, WHITE);
	player->draw();
}

Scenes GameScene::update(float dt)
{
	UpdatePhysics();
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

	if (currentLdtkLevel->hasBgImage())
	{
		cout << "Drawing background image" << endl;
		auto img = currentLdtkLevel->getBgImage();
		auto imgTex = LoadTexture(AppConstants::GetAssetPath(img.path.c_str()).c_str());
		SetTextureFilter(imgTex, TEXTURE_FILTER_TRILINEAR);

		// Draw texture and repeat it 5x5 times withing the specified rect
		DrawTextureQuad(imgTex, {5, 5}, {0, 0}, {0, 0, GameConstants::WorldWidth, GameConstants::WorldHeight}, WHITE);
	}

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
				auto tile_size = float(layer.getTileset().tile_size);

				Rectangle source_rect = {
					.x = float(source_pos.x),
					.y = float(source_pos.y),
					.width = tile.flipX ? -tile_size : tile_size,
					.height = tile.flipY ? -tile_size : tile_size,
				};

				Vector2 target_pos = {
					(float)tile.position.x,
					(float)tile.position.y,
				};

				DrawTextureRec(currentTilesetTexture, source_rect, target_pos, WHITE);

				// if tile is solid then create physics
				auto gx = tile.position.x / tile_size;
				auto gy = tile.position.y / tile_size;
				auto intGridInfo = layer.getIntGridVal(gx, gy);

				if (intGridInfo.name == "Floor")
				{
					// auto body = CreatePhysicsBodyRectangle({target_pos.x + 1, target_pos.y + 1}, tile_size - 1, tile_size - 1, 10);

					// this makes it a static body
					// body->enabled = false;
				}
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