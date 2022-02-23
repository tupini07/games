#pragma once

#include <raylib.h>
#include <box2d/box2d.h>
#include <LDtkLoader/Entity.hpp>

class Player
{
private:
    static const int MOVE_SPEED = 300;
    static const int MIN_RADIUS = 10;

    int radius;
    float radius_timer;

    Texture2D sprite;
    b2Body *body{};

public:
    Player();
    ~Player();

    void update(float dt);
    void draw();

    void init_for_level(const ldtk::Entity *entity, b2World *physicsWorld);
};
