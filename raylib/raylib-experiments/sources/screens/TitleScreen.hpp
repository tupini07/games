#pragma once

#include "BaseScreen.hpp"

class TitleScreen : public BaseScreen
{
private:
public:
	TitleScreen();
	~TitleScreen();

	void draw();
	void update(float dt);
};
