import 'dart:async';
import 'dart:ui';

import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/scenes/babu_scene.dart';
import 'package:pixel_adventure/scenes/duck_scene.dart';
import 'package:pixel_adventure/scenes/intro_scene.dart';

class PixelAdventure extends FlameGame
    with HasKeyboardHandlerComponents, SingleGameInstance {
  late final RouterComponent router;
  Color customBackgroundColor = const Color(0xFF211F30);
  @override
  Color backgroundColor() => customBackgroundColor;

  @override
  FutureOr<void> onLoad() async {
    // could be problematic if we have A LOT of images. This loads them all in
    // cache
    await images.loadAllImages();

    add(router = RouterComponent(initialRoute: "intro", routes: {
      "intro": Route(IntroScene.new),
      "babu": Route(BabuScene.new, maintainState: false),
      "duck": Route(DuckScene.new, maintainState: false),
    }));

    return super.onLoad();
  }
}
