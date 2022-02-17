#pragma once

#include "BaseScreen.hpp"

class TitleScreen : public BaseScreen
{
private:
public:
	TitleScreen();
	~TitleScreen();

	void draw() override;
	Screens update(float dt) override;
};
