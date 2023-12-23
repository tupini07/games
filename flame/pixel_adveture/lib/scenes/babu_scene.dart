import 'dart:math';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame_audio/flame_audio.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class BallComponent extends CircleComponent with HasGameRef<PixelAdventure> {
  static final rng = Random();
  late final double _decreaseSpeed;
  late final Paint _fillPaint;
  late final Paint _outlinePaint;

  BallComponent(position) : super(position: position) {
    var screenWidth = game.size.x;
    var screenHeight = game.size.y;

    anchor = Anchor.center;

    var maxRadius = min(screenWidth, screenHeight) / 3;

    _decreaseSpeed = max(8, rng.nextDouble() * (maxRadius * 0.8));
    radius = rng.nextDouble() * maxRadius;
    // Random fill color
    _fillPaint = Paint()
      ..color = Color.fromRGBO(
        rng.nextInt(256),
        rng.nextInt(256),
        rng.nextInt(256),
        1,
      );

    // Random outline color
    _outlinePaint = Paint()
      ..color = Color.fromRGBO(
        rng.nextInt(256),
        rng.nextInt(256),
        rng.nextInt(256),
        1,
      )
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
  }

  @override
  void render(Canvas canvas) {
    var centerOffset = Offset(size.x / 2, size.y / 2);
    canvas.drawCircle(centerOffset, radius, _fillPaint);
    canvas.drawCircle(centerOffset, radius, _outlinePaint);
  }

  @override
  void update(double dt) {
    super.update(dt);

    // Decrease the radius
    radius -= _decreaseSpeed * dt;

    // Remove the ball when its radius is 0 or less
    if (radius <= 0) {
      removeFromParent();
    }
  }
}

class BabuScene extends Component
    with TapCallbacks, KeyboardHandler, HasGameRef<PixelAdventure> {
  late final List<String> audios = [
    "effects/coin1.wav",
    "effects/jump1.wav",
    "effects/jump2.wav",
    "effects/jump3.wav",
    "effects/jump4.wav",
  ];

  @override
  void onMount() async {
    super.onMount();
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (event.isKeyPressed(LogicalKeyboardKey.escape)) {
      game.router.pushReplacementNamed("intro");
    }

    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onTapDown(TapDownEvent event) async {
    if (game.playSounds) {
      await FlameAudio.play(audios[Random().nextInt(audios.length)]);
    }

    var ball = BallComponent(event.localPosition);
    add(ball);
  }

  @override
  bool containsLocalPoint(Vector2 point) => true;
}
