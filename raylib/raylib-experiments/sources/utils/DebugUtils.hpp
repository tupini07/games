#pragma once

#define SHOW_DEBUG

#include <string>

#include <raylib.h>
#include <fmt/core.h>

using namespace std;

namespace DebugUtils
{
    inline void draw_physics_objects_bounding_boxes()
    {
#ifdef SHOW_DEBUG
        // Show outline of physic bodies. This is taken directly from https://www.raylib.com/examples/physics/loader.html?name=physics_demo
        // auto bc = GetPhysicsBodiesCount();
        // for (int i = 0; i < bc; i++)
        // {
        //     auto b = GetPhysicsBody(i);
        //     DrawCircle(b->position.x, b->position.y, 2, BLUE);

        //     // this methos of forcing precision on string is horrible
        //     string posx_str = to_string(b->position.x);
        //     string posy_str = to_string(b->position.y);
        //     string debugPosStr = "(x:" + posx_str.substr(0, posx_str.find(".")) + " y:" + posx_str.substr(0, posx_str.find(".")) + ")";
        //     auto textWidth = MeasureText(debugPosStr.c_str(), 8);
        //     DrawRectangle(b->position.x, b->position.y, textWidth, 8, {130, 130, 130, 200});
        //     DrawText(debugPosStr.c_str(), b->position.x, b->position.y, 9, WHITE);

        //     int vertexCount = GetPhysicsShapeVerticesCount(i);
        //     for (int j = 0; j < vertexCount; j++)
        //     {
        //         Vector2 vertexA = GetPhysicsShapeVertex(b, j);

        //         int jj = (((j + 1) < vertexCount) ? (j + 1) : 0); // Get next vertex or first to close the shape
        //         Vector2 vertexB = GetPhysicsShapeVertex(b, jj);

        //         DrawLineV(vertexA, vertexB, GREEN); // Draw a line between two vertex positions
        //     }
        // }
#endif
    }

    inline void println(string str)
    {
#ifdef SHOW_DEBUG
        cout << "DEBUG: " << str << endl;
#endif
    }
}