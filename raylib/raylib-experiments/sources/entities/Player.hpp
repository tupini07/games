#pragma once

class Player
{
private:
    static const int MOVE_SPEED = 300;
    static const int MIN_RADIUS = 10;

    int pos_x;
    int pos_y;
    int radius;
    float radius_timer;

public:
    Player(/* args */);
    ~Player();

    void update(float dt);
    void draw();
};
