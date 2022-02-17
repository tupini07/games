#pragma once

#include "raylib.h"
#include "BaseScreen.hpp"

class TitleScreen : public BaseScreen
{
private:
	Texture2D texture;

public:
	TitleScreen();
	~TitleScreen();

	void draw() override;
	Screens update(float dt) override;
};
