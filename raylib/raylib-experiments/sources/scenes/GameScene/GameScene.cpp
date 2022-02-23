#include <sstream>

#include <raylib.h>
#include <box2d/box2d.h>
#include <LDtkLoader/World.hpp>
#include <fmt/core.h>

#include <Constants.hpp>
#include <utils/DebugUtils.hpp>

#include "GameScene.hpp"
#include "../Scenes.hpp"

using namespace std;

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
	delete world;

	UnloadTexture(renderedLevelTexture);
	UnloadTexture(currentTilesetTexture);
}

void GameScene::draw()
{
	ClearBackground(RAYWHITE);
	DrawTextureRec(renderedLevelTexture,
				   {0, 0, (float)renderedLevelTexture.width, (float)-renderedLevelTexture.height},
				   {0, 0}, WHITE);

	player->draw();

	// DEBUG stuff
	DebugUtils::draw_physics_objects_bounding_boxes(world);
}

Scenes GameScene::update(float dt)
{
	const float timeStep = 1.0f / 60.0f;
	const int32 velocityIterations = 6;
	const int32 positionIterations = 2;

	world->Step(timeStep, velocityIterations, positionIterations);

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

	if (world != nullptr)
	{
		// if we had an old world then delete it and recreate
		// a new one for the new level
		delete world;
	}

	b2Vec2 gravity(0.0f, 10.0f);
	world = new b2World(gravity);

	current_level = lvl;

	currentLdtkLevel = &ldtkWorld->getLevel(current_level);

	// DebugUtils::print("hi I {} want", 123);
	// DebugUtils::print("----------------------------------------------");
	// DebugUtils::print("Loaded LDTK map with {}  levels in it", ldtkWorld->allLevels().size());
	// DebugUtils::print("The loaded level is {} and it has {} layers", current_level, currentLdtkLevel->allLayers().size());
	// for (auto &&layer : currentLdtkLevel->allLayers())
	// {
	// 	DebugUtils::print("  - {}", layer.getName());
	// }

	auto testTileLayerTileset = currentLdtkLevel->getLayer("TileLayer").getTileset();
	// stream << "The path to the tile layer tileset is: " << testTileLayerTileset.path << endl;
	// stream << "----------------------------------------------" << endl;

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

				/**
				 * Note for self: below is how we would add physcis entities for
				 * every solid block. But it seem that the physac library
				 * doesn't work very well when there are many bodies in the scene.
				 *
				 */
				// if tile is solid then create physics
				auto gx = tile.position.x / tile_size;
				auto gy = tile.position.y / tile_size;
				auto intGridInfo = currentLdtkLevel->getLayer("PhysicsLayer").getIntGridVal(gx, gy);

				if (intGridInfo.name == "HasColission")
				{
					auto halfGridSize = GameConstants::CellSize / 2;

					b2BodyDef bodyDef;
					bodyDef.position.Set((target_pos.x + halfGridSize) / GameConstants::PhysicsWorldScale,
										 (target_pos.y + halfGridSize) / GameConstants::PhysicsWorldScale);

					b2Body *body = world->CreateBody(&bodyDef);

					b2PolygonShape groundBox;
					groundBox.SetAsBox(1, 1);

					body->CreateFixture(&groundBox, 0.0f);
					cout << "Created physic body at x:" << body->GetPosition().x * GameConstants::PhysicsWorldScale << " y:" << body->GetPosition().y * GameConstants::PhysicsWorldScale << endl;
				}
			}
		}
	}

	EndTextureMode();
	renderedLevelTexture = renderTexture.texture;

	// get entity positions
	cout << "Entities in level:" << endl;
	for (auto &&entity : currentLdtkLevel->getLayer("Entities").allEntities())
	{
		cout << "  - " << entity.getName() << endl;

		if (entity.getName() == "Player")
		{
			player->init_for_level(&entity, world);
		}
	}
}