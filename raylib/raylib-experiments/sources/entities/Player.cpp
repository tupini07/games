#include <math.h>
#include <unordered_map>
#include <vector>

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

	auto make_player_frame_rect = [](float frame_num) -> Rectangle
	{
		return {.x = frame_num * 23.0f, .y = 0.0f, .width = 23.0f, .height = 23.0f};
	};

	animation_map["idle"] = {
		make_player_frame_rect(0),
		make_player_frame_rect(1),
		make_player_frame_rect(2),
	};

	animation_map["walk"] = {
		make_player_frame_rect(3),
		make_player_frame_rect(4),
		make_player_frame_rect(5),
	};

	animation_map["jump_start"] = {
		make_player_frame_rect(6),
	};

	animation_map["jump_apex"] = {
		make_player_frame_rect(7),
	};

	animation_map["jump_fall"] = {
		make_player_frame_rect(8),
	};
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
	// TODO Player gets stuck agains walls if it moves in the direction of wall when adjacent to it
	//        ^ velocity should not be set in direction of wall if player is colliding with said wall
	if (IsKeyDown(KEY_LEFT))
	{
		looking_right = false;
		set_velocity_x(-effective_speed);
	}

	if (IsKeyDown(KEY_RIGHT))
	{
		looking_right = true;
		set_velocity_x(effective_speed);
	}

	// TODO only jump if touching ground
	if (IsKeyPressed(KEY_UP) || IsKeyPressed(KEY_SPACE))
	{
		set_velocity_y(-25);
	}
}

void Player::draw()
{
	auto spritePosX = (body->GetPosition().x * GameConstants::PhysicsWorldScale) - 12;
	auto spritePosY = (body->GetPosition().y * GameConstants::PhysicsWorldScale) - 13;

	DrawTexturePro(sprite,
				   {0, 0, (looking_right ? 1.0f : -1.0f) * 23, 23},
				   {spritePosX, spritePosY, 23, 23},
				   {0, 0},
				   0.0f,
				   WHITE);
}

void Player::init_for_level(const ldtk::Entity *entity, b2World *physicsWorld)
{
	auto pos = entity->getPosition();

	DebugUtils::print("Setting player position to x:{} and y:{}", pos.x, pos.y);

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