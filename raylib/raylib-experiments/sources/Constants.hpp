#pragma once

#include <string>

using namespace std;

namespace AppConstants {
    const string WindowTitle = "Window Title";
    const int ScreenWidth = 800;
    const int ScreenHeight = 450;

    inline string GetAssetPath(string assetName) {
        return ASSETS_PATH"" + assetName;
    }
}