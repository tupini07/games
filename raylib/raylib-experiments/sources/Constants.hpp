#pragma once

#include <string>

using namespace std;

namespace AppConstants {
    const string WindowTitle = "Window Title";
    const int ScreenWidth = 600;
    const int ScreenHeight = 600;

    inline string GetAssetPath(string assetName) {
        return ASSETS_PATH"" + assetName;
    }
}