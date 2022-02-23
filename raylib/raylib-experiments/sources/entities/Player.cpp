#include <math.h>
#include <sstream>

#include <raylib.h>
#include <box2d/box2d.h>

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
		body->ApplyForceToCenter({-effective_speed, 0}, true);
	}

	if (IsKeyDown(KEY_RIGHT))
	{
		body->ApplyForceToCenter({effective_speed, 0}, true);
	}

	// TODO only jump if touching ground
	if (IsKeyPressed(KEY_UP))
	{
		body->ApplyForceToCenter({0, -300}, true);
	}
}

void Player::draw()
{
	// DrawCircle(body->position.x, body->position.y, this->radius, GREEN);
	DrawTexture(sprite,
				(body->GetPosition().x * GameConstants::PhysicsWorldScale) - 12,
				(body->GetPosition().y * GameConstants::PhysicsWorldScale) - 12,
				WHITE);
}

void Player::init_for_level(const ldtk::Entity *entity, b2World *physicsWorld)
{
	auto pos = entity->getPosition();

	stringstream stream;
	stream << "Setting player position to x:" << pos.x << " and y:" << pos.y << endl;
	DebugUtils::println(stream.str());

	b2BodyDef bodyDef;
	bodyDef.type = b2_dynamicBody;
	bodyDef.position.Set((float)pos.x / GameConstants::PhysicsWorldScale,
						 (float)pos.y / GameConstants::PhysicsWorldScale);
	bodyDef.fixedRotation = true;

	this->body = physicsWorld->CreateBody(&bodyDef);

	b2PolygonShape dynamicBox;
	dynamicBox.SetAsBox(1, 1);

	b2FixtureDef fixtureDef;
	fixtureDef.shape = &dynamicBox;
	fixtureDef.density = 1.0f;
	fixtureDef.friction = 0.4f;

	body->CreateFixture(&fixtureDef);
}