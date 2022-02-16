#pragma once

class BaseScreen
{
public:
    virtual void update(float dt);
    virtual void draw();
};