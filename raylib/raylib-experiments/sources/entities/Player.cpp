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
	this->sprite = LoadTexture(AppConstants::GetAssetPath("dinoCharactersVersion1.1/sheets/DinoSprites - vita.png").c_str());
}

Player::~Player()
{
	UnloadTexture(sprite);
}

void Player::update(float dt)
{
	const float horizontalDampeningFactor = 1;
	auto effective_speed = 15.0f;

	// dampen horizontal movement
	set_velocity_x(body->GetLinearVelocity().x * (1 - dt * horizontalDampeningFactor));

	// TODO Cap velocities
	if (IsKeyDown(KEY_LEFT))
	{
		set_velocity_x(-effective_speed);
	}

	if (IsKeyDown(KEY_RIGHT))
	{
		set_velocity_x(effective_speed);
	}

	// TODO only jump if touching ground
	if (IsKeyPressed(KEY_UP))
	{
		set_velocity_y(-25);
	}
}

void Player::draw()
{
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
	fixtureDef.friction = 10.0f;

	body->CreateFixture(&fixtureDef);
}

void Player::set_velocity_x(float vx)
{
	body->SetLinearVelocity({
		vx,
		body->GetLinearVelocity().y,
	});
}

void Player::set_velocity_y(float vy)
{
	body->SetLinearVelocity({
		body->GetLinearVelocity().x,
		vy,
	});
}

void Player::set_velocity_xy(float vx, float vy)
{
	body->SetLinearVelocity({vx, vy});
}