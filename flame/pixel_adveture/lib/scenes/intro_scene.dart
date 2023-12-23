import 'dart:async';

import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class IntroScene extends Component with HasGameRef<PixelAdventure> {
  @override
  FutureOr<void> onLoad() {
    game.customBackgroundColor = const Color.fromARGB(255, 230, 225, 214);
    game.overlays.addEntry(
        "intro_scene_menu",
        (context, ogGame) => Scaffold(
              backgroundColor: const Color.fromARGB(255, 230, 225, 214),
              body: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '🦆 Select Minigame',
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => game.router.pushReplacementNamed("babu"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan),
                      child: const Text('Go to babu scene'),
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () => game.router.pushReplacementNamed("duck"),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.cyan),
                      child: const Text('Go to duck scene'),
                    ),
                  ],
                ),
              ),
            ));

    game.overlays.add("intro_scene_menu");
    return super.onLoad();
  }

  @override
  void onRemove() {
    game.overlays.remove("intro_scene_menu");
    super.onRemove();
  }
}
