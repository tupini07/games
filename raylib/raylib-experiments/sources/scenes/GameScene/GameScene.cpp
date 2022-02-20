#include <iostream>

#include <raylib.h>
#include <extras/physac.h>
#include <LDtkLoader/World.hpp>

#include <Constants.hpp>
#include "GameScene.hpp"
#include "../Scenes.hpp"
#include "LevelDefinitions.hpp"

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

	// DEBUG stuff

	// Show outline of physic bodies. This is taken directly from https://www.raylib.com/examples/physics/loader.html?name=physics_demo
	auto bc = GetPhysicsBodiesCount();
	for (int i = 0; i < bc; i++)
	{
		auto b = GetPhysicsBody(i);
		DrawCircle(b->position.x, b->position.y, 2, BLUE);

		// this methos of forcing precision on string is horrible
		string posx_str = to_string(b->position.x);
		string posy_str = to_string(b->position.y);
		string debugPosStr = "(x:" + posx_str.substr(0, posx_str.find(".")) + " y:" + posx_str.substr(0, posx_str.find(".")) + ")";
		auto textWidth = MeasureText(debugPosStr.c_str(), 8);
		DrawRectangle(b->position.x, b->position.y, textWidth, 8, {130, 130, 130, 200});
		DrawText(debugPosStr.c_str(), b->position.x, b->position.y, 9, WHITE);

		int vertexCount = GetPhysicsShapeVerticesCount(i);
		for (int j = 0; j < vertexCount; j++)
		{
			Vector2 vertexA = GetPhysicsShapeVertex(b, j);

			int jj = (((j + 1) < vertexCount) ? (j + 1) : 0); // Get next vertex or first to close the shape
			Vector2 vertexB = GetPhysicsShapeVertex(b, jj);

			DrawLineV(vertexA, vertexB, GREEN); // Draw a line between two vertex positions
		}
	}
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

				/**
				 * Note for self: below is how we would add physcis entities for
				 * every solid block. But it seem that the physac library
				 * doesn't work very well when there are many bodies in the scene.
				 *
				 */
				// if tile is solid then create physics
				// auto gx = tile.position.x / tile_size;
				// auto gy = tile.position.y / tile_size;
				// auto intGridInfo = currentLdtkLevel->getLayer("PhysicsLayer").getIntGridVal(gx, gy);

				// if (intGridInfo.name == "HasColission")
				// {
				// 	auto body = CreatePhysicsBodyRectangle(target_pos, 16, 16, 10);
				// 	cout << "Created physic body on x:" << body->position.x << " y:" << body->position.y << endl;

				// 	// this makes it a static body
				// 	body->enabled = false;
				// }
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

		float wanted_colx = colliderRect.x * GameConstants::CellSize;
		float wanted_coly = colliderRect.y * GameConstants::CellSize;
		float colw = colliderRect.width * GameConstants::CellSize;
		float colh = colliderRect.height * GameConstants::CellSize;

		float transformed_colx = wanted_colx + colw / 2;
		float tramsformed_coly = wanted_coly + colh / 2;

		auto body = CreatePhysicsBodyRectangle({transformed_colx, tramsformed_coly}, colw, colh, 10);
		cout << "Created physic body on x:" << body->position.x << " y:" << body->position.y << " w:" << colw << " h:" << colh << endl;

		// this makes it a static body
		body->enabled = false;
		body->freezeOrient = true;
	}
}