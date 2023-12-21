import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/services/keyboard_key.g.dart';
import 'package:pixel_adventure/actors/player.dart';

class Level extends World with KeyboardHandler {
  late TiledComponent level;

  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("Level-01.tmx", Vector2(16, 16));

    add(level);

    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("Spawnpoints");

    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.type) {
        case "Player":
          add(Player(
              character: "Mask Dude",
              position: Vector2(spawnPoint.x, spawnPoint.y)));
          break;
        default:
      }
    }

    var rectangle = RectangleComponent(
      position: Vector2(50, 50), // Position of the rectangle
      size: Vector2(100, 100), // Size of the rectangle
      paint: (Paint()..color = Colors.white)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.0, // Outlined rectangle
    );

    add(rectangle);

    return super.onLoad();
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.contains(LogicalKeyboardKey.escape)) {
      // PixelAdventure().switchWorld(IntroScene());
    }

    // TODO: implement onKeyEvent
    return super.onKeyEvent(event, keysPressed);
  }
}
