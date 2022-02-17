#pragma once

#include "BaseScreen.hpp"

class TitleScreen : public BaseScreen
{
private:
public:
	TitleScreen();
	~TitleScreen();

	void draw();
	Screens update(float dt);
};
