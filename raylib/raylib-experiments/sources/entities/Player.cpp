#include <math.h>
#include <iostream>

#include <raylib.h>
#include <extras/physac.h>
#include <LDtkLoader/World.hpp>

#include <Constants.hpp>
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
	auto effective_speed = 35;

	radius_timer += dt;

	if (radius_timer >= 3 && radius >= MIN_RADIUS)
	{
		radius -= 1;
		radius_timer *= 0;
	}

	// TODO Cap velocities
	if (IsKeyDown(KEY_LEFT))
	{
		body->force.x -= effective_speed;
	}

	if (IsKeyDown(KEY_RIGHT))
	{
		body->force.x += effective_speed;
	}

	if (IsKeyPressed(KEY_UP))
	{
		body->force.y -= 300;
	}
}

void Player::draw()
{
	DrawCircle(body->position.x, body->position.y, this->radius, GREEN);
	DrawTexture(sprite, body->position.x, body->position.y, WHITE);
}

void Player::init_for_level(const ldtk::Entity *entity)
{
	auto pos = entity->getPosition();

	cout << "DEBUG: Setting player position to x:" << pos.x << " and y:" << pos.y << endl;

	this->body = CreatePhysicsBodyRectangle({(float)pos.x, (float)pos.y}, 10, 10, 10);
}