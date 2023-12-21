import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame/input.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class IntroScene extends Component with HasGameRef<PixelAdventure> {
  @override
  FutureOr<void> onLoad() {
    game.customBackgroundColor = const Color.fromARGB(255, 230, 225, 214);

    // Add the title
    var title = TextComponent(
        text: '🦆 Select Minigame',
        position: Vector2(10, 10),
        textRenderer: TextPaint(
            style: const TextStyle(
                fontSize: 22,
                color: Colors.black,
                fontWeight: FontWeight.bold,
                decoration: TextDecoration.none)));
    add(title);

    // Add a button
    var buttonText = TextComponent(
        text: 'Go to babu scene',
        textRenderer: TextPaint(
            style: const TextStyle(
                fontSize: 12,
                color: Colors.cyan,
                decoration: TextDecoration.none)));

    var button = ButtonComponent(
      button: PositionComponent(
        size: buttonText.size,
      ),
      position: (title.position.clone()..y += title.size.y + 10),
      children: [buttonText],
      onPressed: () => game.router.pushNamed("babu"),
    );
    add(button);

    // duck
    var duckText = TextComponent(
        text: 'Go to duck scene',
        textRenderer: TextPaint(
            style: const TextStyle(
                fontSize: 12,
                color: Colors.cyan,
                decoration: TextDecoration.none)));

    var duckButton = ButtonComponent(
      button: PositionComponent(
        size: duckText.size,
      ),
      position: (button.position.clone()..y += button.size.y + 10),
      children: [duckText],
      onPressed: () => game.router.pushNamed("duck"),
    );
    add(duckButton);

    return super.onLoad();
  }
}
