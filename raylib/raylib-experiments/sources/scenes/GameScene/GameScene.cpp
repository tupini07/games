#include <sstream>

#include <raylib.h>
#include <box2d/box2d.h>
#include <LDtkLoader/World.hpp>
#include <fmt/core.h>

#include <Constants.hpp>
#include <utils/DebugUtils.hpp>

#include "GameScene.hpp"
#include "../Scenes.hpp"
#include "LevelDefinitions.hpp"

using namespace std;

GameScene::GameScene()
{
	b2Vec2 gravity(0.0f, -10.0f);
	world = new b2World(gravity);

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
	DrawTextureRec(renderedLevelTexture,
				   {0, 0, (float)renderedLevelTexture.width, (float)-renderedLevelTexture.height},
				   {0, 0}, WHITE);
	player->draw();

	// DEBUG stuff
	DebugUtils::draw_physics_objects_bounding_boxes();
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
					b2BodyDef bodyDef;
					bodyDef.type = b2_dynamicBody;
					bodyDef.position.Set(target_pos.x, target_pos.y);

					b2Body *body = world->CreateBody(&bodyDef);

					b2PolygonShape dynamicBox;
					dynamicBox.SetAsBox(1.0f, 1.0f);

					b2FixtureDef fixtureDef;
					fixtureDef.shape = &dynamicBox;
					fixtureDef.density = 1.0f;
					fixtureDef.friction = 0.3f;

					body->CreateFixture(&fixtureDef);
					
					// auto body = CreatePhysicsBodyRectangle(target_pos, 16, 16, 10);
					// cout << "Created physic body on x:" << body->position.x << " y:" << body->position.y << endl;

					// this makes it a static body
					// body->enabled = false;
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
			player->init_for_level(&entity);
		}
	}

	// create physics
	auto collidersInLevel = LevelDefinitions::LevelColliders[current_level];
	for (auto &&colliderRect : collidersInLevel)
	{
		// Origin of physics body is center, so we need to translate from our own coordinates
		// float colx = (colliderRect.x + 1.5) * GameConstants::CellSize;
		// float coly = (colliderRect.y + 0.5) * GameConstants::CellSize;

		// float wanted_colx = colliderRect.x * GameConstants::CellSize;
		// float wanted_coly = colliderRect.y * GameConstants::CellSize;
		// float colw = colliderRect.width * GameConstants::CellSize;
		// float colh = colliderRect.height * GameConstants::CellSize;

		// float transformed_colx = wanted_colx + colw / 2;
		// float tramsformed_coly = wanted_coly + colh / 2;

		// auto body = CreatePhysicsBodyRectangle({transformed_colx, tramsformed_coly}, colw, colh, 10);
		// cout << "Created physic body on x:" << body->position.x << " y:" << body->position.y << " w:" << colw << " h:" << colh << endl;

		// this makes it a static body
		// body->enabled = false;
		// body->freezeOrient = true;
	}
}