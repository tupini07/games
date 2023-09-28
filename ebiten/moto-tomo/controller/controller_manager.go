package controller

import (
	"github.com/hajimehoshi/ebiten/v2"
	"github.com/hajimehoshi/ebiten/v2/inpututil"
	"github.com/tupini07/moto-tomo/logging"
)

type Action int

const (
	Up Action = iota
	Down
	Left
	Right
)

var actionToKeysMap = make(map[Action][]ebiten.Key)

func Map(action Action, keys ...ebiten.Key) {
	existingKeys, ok := actionToKeysMap[action]
	if !ok {
		actionToKeysMap[action] = keys
		return
	}

	existingKeys = append(existingKeys, keys...)
	actionToKeysMap[action] = existingKeys
}

func IsActionPressed(action Action) bool {
	keys, ok := actionToKeysMap[action]
	if !ok {
		logging.Debug("Tried to check for unregistered action in IsActionPressed: %v", action)
		return false
	}

	for _, key := range keys {
		if ebiten.IsKeyPressed(key) {
			return true
		}
	}

	return false
}

func IsActionJustPressed(action Action) bool {
	keys, ok := actionToKeysMap[action]
	if !ok {
		logging.Debug("Tried to check for unregistered action in IsActionJustPressed: %v", action)
		return false
	}

	for _, key := range keys {
		if inpututil.IsKeyJustPressed(key) {
			return true
		}
	}

	return false
}
