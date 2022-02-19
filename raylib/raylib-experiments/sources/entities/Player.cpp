#include <math.h>
#include <iostream>

#include <raylib.h>
#include <LDtkLoader/World.hpp>

#include <Constants.hpp>
#include "Player.hpp"

Player::Player()
{
	this->pos_x = 10;
	this->pos_y = 10;
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
	auto effective_speed = floor(MOVE_SPEED * dt);

	radius_timer += dt;

	if (radius_timer >= 3 && radius >= MIN_RADIUS)
	{
		radius -= 1;
		radius_timer *= 0;
	}

	if (IsKeyDown(KEY_LEFT))
	{
		this->pos_x -= effective_speed;
	}

	if (IsKeyDown(KEY_RIGHT))
	{
		this->pos_x += effective_speed;
	}

	if (IsKeyDown(KEY_UP))
	{
		this->pos_y -= effective_speed;
	}

	if (IsKeyDown(KEY_DOWN))
	{
		this->pos_y += effective_speed;
	}
}

void Player::draw()
{
	DrawCircle(this->pos_x, this->pos_y, this->radius, GREEN);
	DrawTexture(sprite, pos_x, pos_y, WHITE);
}

void Player::init_for_level(const ldtk::Entity *entity)
{
	using namespace std;
	auto pos = entity->getPosition();

	cout << "DEBUG: Setting player position to x:" << pos.x << " and y:" << pos.y << endl;

	this->pos_x = pos.x;
	this->pos_y = pos.y;
}