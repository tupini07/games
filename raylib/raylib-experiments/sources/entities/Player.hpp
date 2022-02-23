#pragma once

#include <raylib.h>
#include <LDtkLoader/Entity.hpp>

class Player
{
private:
    static const int MOVE_SPEED = 300;
    static const int MIN_RADIUS = 10;

    int radius;
    float radius_timer;

    Texture2D sprite;
    // PhysicsBody body;

public:
    Player(/* args */);
    ~Player();

    void update(float dt);
    void draw();

    void init_for_level(const ldtk::Entity *entity);
};
