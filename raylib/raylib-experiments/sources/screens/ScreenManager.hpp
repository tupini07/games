#pragma once

#include "LDtkLoader/World.hpp"

#include "BaseScreen.hpp"
#include "TitleScreen.hpp"
#include "GameScreen.hpp"

enum Screen
{
	UNSET,
	TITLE,
	GAME,
};

class ScreenManager
{
private:
	static BaseScreen *current_screen;
	static ldtk::World *ldtkWorld;

public:
	static void set_current_screen(Screen screen);
	static void initialize();

	static void update(float dt);
	static void draw();
};

BaseScreen *ScreenManager::current_screen;
ldtk::World *ScreenManager::ldtkWorld;

void ScreenManager::initialize()
{
	ScreenManager::ldtkWorld = new ldtk::World();

	ScreenManager::ldtkWorld->loadFromFile(ASSETS_PATH "world.ldtk");
	ScreenManager::set_current_screen(UNSET);
}

void ScreenManager::set_current_screen(Screen screen)
{
	if (ScreenManager::current_screen != nullptr)
	{
		delete ScreenManager::current_screen;
	}

	switch (screen)
	{
	case UNSET:
		ScreenManager::current_screen = nullptr;
		break;

	case TITLE:
		ScreenManager::current_screen = new TitleScreen();
		break;
	case GAME:
		ScreenManager::current_screen = new GameScreen();
		break;
	}
}

void ScreenManager::update(float dt)
{
	if (ScreenManager::current_screen != nullptr)
	{
		ScreenManager::current_screen->update(dt);
	}
}

void ScreenManager::draw()
{
	if (ScreenManager::current_screen != nullptr)
	{
		ScreenManager::current_screen->draw();
	}
}