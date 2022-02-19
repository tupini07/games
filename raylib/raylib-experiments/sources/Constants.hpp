#pragma once

#include <string>

using namespace std;

namespace GameConstants
{
    const int WorldWidth = 400;
    const int WorldHeight = 400;
    const int CellSize = 16;
}

namespace AppConstants
{
    const string WindowTitle = "Window Title";
    const int ScreenWidth = GameConstants::WorldWidth * 2;
    const int ScreenHeight = GameConstants::WorldHeight * 2;

    inline string GetAssetPath(string assetName)
    {
        return ASSETS_PATH "" + assetName;
    }
}
