#pragma once

#include "Screens.hpp"

class BaseScreen
{
public:
    virtual ~BaseScreen() = default;
    virtual void draw() = 0;
    virtual Screens update(float dt) = 0;
};