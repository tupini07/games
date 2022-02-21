#include <math.h>
#include <sstream>

#include <raylib.h>
#include <extras/physac.h>
#include <LDtkLoader/World.hpp>

#include <Constants.hpp>
#include <utils/DebugUtils.hpp>

#include "Player.hpp"

using namespace std;

Player::Player()
{
	this->radius = 8;
	this->radius_timer = 0.0f;

	this->sprite = LoadTexture(AppConstants::GetAssetPath("dinoCharactersVersion1.1/sheets/DinoSprites - vita.png").c_str());
}

Player::~Player()
{
	UnloadTexture(sprite);
}

void Player::update(float dt)
{
	auto effective_speed = 35.0f;

	radius_timer += dt;

	if (radius_timer >= 3 && radius >= MIN_RADIUS)
	{
		radius -= 1;
		radius_timer *= 0;
	}

	// TODO Cap velocities
	if (IsKeyDown(KEY_LEFT))
	{
		PhysicsAddForce(body, {-effective_speed, 0});
	}

	if (IsKeyDown(KEY_RIGHT))
	{
		PhysicsAddForce(body, {effective_speed, 0});
	}

	if (IsKeyPressed(KEY_UP))
	{
		PhysicsAddForce(body, {0, -300});
	}
}

void Player::draw()
{
	// DrawCircle(body->position.x, body->position.y, this->radius, GREEN);
	DrawTexture(sprite, body->position.x - 0.7f * GameConstants::CellSize, body->position.y - 1 * GameConstants::CellSize, WHITE);
}

void Player::init_for_level(const ldtk::Entity *entity)
{
	auto pos = entity->getPosition();

	// stringstream stream;
	// stream << "Setting player position to x:" << pos.x << " and y:" << pos.y << endl;
	// DebugUtils::println(stream.str());

	this->body = CreatePhysicsBodyRectangle({(float)pos.x, (float)pos.y}, 10, 10, 10);
	body->freezeOrient = true;
	body->dynamicFriction = 0.4f;
}