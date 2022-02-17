#include <math.h>

#include "raylib.h"

#include "Player.hpp"

Player::Player()
{
	this->pos_x = 10;
	this->pos_y = 10;
	this->radius = 20;
	this->radius_timer = 0.0f;
}

Player::~Player()
{
}

void Player::update(float dt)
{
	auto effective_speed = floor(MOVE_SPEED * dt);

	radius_timer += dt;

	if (radius_timer >= 3 && radius >= MIN_RADIUS) {
		radius -= 1;
		radius_timer *= 0;
	}

	if (IsKeyDown(KEY_LEFT)) {
		this->pos_x -= effective_speed;
	}

	if (IsKeyDown(KEY_RIGHT)) {
		this->pos_x += effective_speed;
	}

	if (IsKeyDown(KEY_UP)) {
		this->pos_y -= effective_speed;
	}

	if (IsKeyDown(KEY_DOWN)) {
		this->pos_y += effective_speed;
	}
}

void Player::draw()
{
	DrawCircle(this->pos_x, this->pos_y, this->radius, GREEN);
}
