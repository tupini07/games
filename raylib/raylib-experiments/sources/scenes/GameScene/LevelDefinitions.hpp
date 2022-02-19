#pragma once

#include <vector>
#include <raylib.h>

#include <Constants.hpp>

using namespace std;

namespace LevelDefinitions
{
    // Note: all these coordinates are in GRID SPACE
    const vector<vector<Rectangle>> LevelColliders = {
        {
            // level 0
            {3, 12, 3, 1},
            {8, 12, 3, 1},
            {2, 2, 10, 1},

        }};
}