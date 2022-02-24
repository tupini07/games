#pragma once

#include <raylib.h>
#include <box2d/box2d.h>
#include <LDtkLoader/Entity.hpp>

class Player
{
private:
    Texture2D sprite;
    b2Body *body{};

    void set_velocity_x(float vx);
    void set_velocity_y(float vy);
    void set_velocity_xy(float vx, float vy);

public:
    Player();
    ~Player();

    void update(float dt);
    void draw();

    void init_for_level(const ldtk::Entity *entity, b2World *physicsWorld);
};
