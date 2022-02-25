#pragma once

#include <unordered_map>
#include <vector>

#include <raylib.h>
#include <box2d/box2d.h>
#include <LDtkLoader/Entity.hpp>

using namespace std;

enum PlayerAnimationState
{
    IDLE,
    WALK,
    JUMP_START,
    JUMP_APEX,
    JUMP_FALL
};

class Player
{
private:
    Texture2D sprite;
    b2Body *body{};

    bool looking_right = true;

    const float animation_frame_duration = 0.2f;
    float animation_ticker = animation_frame_duration;

    size_t current_anim_frame = 0;
    PlayerAnimationState anim_state = PlayerAnimationState::IDLE;
    unordered_map<PlayerAnimationState, vector<Rectangle>> animation_map;

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
